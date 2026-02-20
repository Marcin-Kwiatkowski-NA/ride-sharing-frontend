import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/network/stomp_connection_state.dart';
import '../../../../core/network/stomp_connection_state_provider.dart';
import '../../../../core/network/stomp_service_provider.dart';
import '../../../../core/providers/auth_session_provider.dart';
import '../../data/chat_repository.dart';
import '../../data/dto/message_dto.dart';
import '../../data/dto/message_status_update_dto.dart';
import '../../domain/chat_presentation.dart';
import '../../domain/message_status.dart';
import '../../domain/message_ui_model.dart';
import 'inbox_provider.dart';

part 'chat_thread_provider.freezed.dart';
part 'chat_thread_provider.g.dart';

@freezed
sealed class ChatThreadState with _$ChatThreadState {
  const factory ChatThreadState({
    @Default([]) List<MessageUiModel> messages,
    @Default(false) bool isLoadingInitial,
    @Default(false) bool isLoadingEarlier,
    @Default(false) bool hasMoreEarlier,
    Object? error,
  }) = _ChatThreadState;
}

/// Chat thread notifier merging REST history + live STOMP messages.
///
/// Auto-disposed when [ChatScreen] is popped — STOMP subscription
/// and message memory released via [ref.onDispose].
@riverpod
class ChatThread extends _$ChatThread {
  static final _timeFormat = DateFormat('HH:mm');
  static const _uuid = Uuid();

  final List<MessageDto> _rawMessages = [];
  final Set<String> _messageIds = {};
  final List<String> _pendingIds = [];
  VoidCallback? _unsubscribe;
  VoidCallback? _unsubscribeStatus;

  /// Debounce timer for batching delivery/read ACKs.
  Timer? _ackTimer;

  /// Latest peer message ID seen — used for debounced ACKs.
  String? _latestPeerMessageId;

  @override
  ChatThreadState build(String conversationId) {
    // LISTEN (not watch) connection state — no rebuild, just react.
    ref.listen(stompConnectionStateProvider, (prev, next) {
      final connState =
          next.value ?? StompConnectionState.disconnected;
      if (connState == StompConnectionState.connected) {
        _catchUpMessages();
      }
    });

    ref.onDispose(() {
      _unsubscribe?.call();
      _unsubscribeStatus?.call();
      _ackTimer?.cancel();
    });

    // One-time REST load
    Future.microtask(_loadInitialMessages);
    return const ChatThreadState(isLoadingInitial: true);
  }

  Future<void> _loadInitialMessages() async {
    try {
      final repo = ref.read(chatRepositoryProvider);
      final dtos = await repo.getMessages(conversationId, limit: 50);

      if (!ref.mounted) return;

      final currentUserId = ref.read(authSessionKeyProvider);

      _rawMessages.clear();
      _messageIds.clear();
      for (final dto in dtos) {
        _rawMessages.add(dto);
        _messageIds.add(dto.id);
      }

      state = ChatThreadState(
        messages: ChatPresentation.toMessageUiModels(
          dtos,
          currentUserId: currentUserId,
        ),
        hasMoreEarlier: dtos.length >= 50,
      );

      // Mark-read ACK for messages loaded via REST
      _schedulePostLoadReadAck(currentUserId);
    } catch (e) {
      if (!ref.mounted) return;
      state = ChatThreadState(error: e);
    }

    if (ref.mounted) {
      _subscribeToStomp();
      _subscribeToStatusUpdates();
    }
  }

  void _subscribeToStomp() {
    final service = ref.read(stompServiceControllerProvider);
    final currentUserId = ref.read(authSessionKeyProvider);

    _unsubscribe?.call();
    _unsubscribe = service.subscribe(
      '/topic/conversation/$conversationId',
      (frame) {
        if (frame.body == null || !ref.mounted) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final dto = MessageDto.fromJson(json);
          _mergeIncomingMessage(dto, currentUserId: currentUserId);
        } catch (e, st) {
          dev.log(
            'STOMP frame parse error',
            name: 'ChatThread',
            error: e,
            stackTrace: st,
          );
        }
      },
    );
  }

  void _subscribeToStatusUpdates() {
    final service = ref.read(stompServiceControllerProvider);

    _unsubscribeStatus?.call();
    _unsubscribeStatus = service.subscribe(
      '/user/queue/message-status',
      (frame) {
        if (frame.body == null || !ref.mounted) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final update = MessageStatusUpdateDto.fromJson(json);
          if (update.conversationId == conversationId) {
            _applyStatusUpdate(MessageStatus.fromBackend(update.status));
          }
        } catch (e, st) {
          dev.log(
            'Status update parse error',
            name: 'ChatThread',
            error: e,
            stackTrace: st,
          );
        }
      },
    );
  }

  /// Forward-sweep all own outgoing messages to the new status.
  void _applyStatusUpdate(MessageStatus newStatus) {
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (!m.isFromCurrentUser) return m;
        final current = m.status;
        if (current == null) return m;
        // Only upgrade status (sent → delivered → read), never downgrade
        if (current < newStatus &&
            current != MessageStatus.pending &&
            current != MessageStatus.failed) {
          return m.copyWith(status: newStatus);
        }
        return m;
      }).toList(),
    );
  }

  /// Lightweight catch-up after reconnect — fetch messages since the
  /// last known message without resetting state to loading.
  Future<void> _catchUpMessages() async {
    if (_rawMessages.isEmpty) return;

    try {
      final repo = ref.read(chatRepositoryProvider);
      final latest = _rawMessages.last;
      final newDtos = await repo.getMessages(
        conversationId,
        since: latest.createdAt,
        limit: 50,
      );

      if (!ref.mounted) return;

      final currentUserId = ref.read(authSessionKeyProvider);
      for (final dto in newDtos) {
        _mergeIncomingMessage(dto, currentUserId: currentUserId);
      }
    } catch (_) {
      // Best-effort catch-up; live messages will still arrive via STOMP
    }
  }

  void _mergeIncomingMessage(MessageDto dto, {int? currentUserId}) {
    if (_messageIds.contains(dto.id)) return; // Dedup

    // Own-message echo: replace the oldest pending optimistic message
    // instead of appending a duplicate.
    final isOwnEcho = currentUserId != null && dto.senderId == currentUserId;
    if (isOwnEcho && _pendingIds.isNotEmpty) {
      _confirmPending(dto, currentUserId: currentUserId);
      return;
    }

    _rawMessages.add(dto);
    _messageIds.add(dto.id);

    state = state.copyWith(
      messages: [
        ...state.messages,
        ChatPresentation.toMessageUiModel(dto, currentUserId: currentUserId),
      ],
    );

    // Peer message arrived — schedule debounced ACKs
    if (!isOwnEcho) {
      _scheduleDebouncedAck(dto.id);
    }
  }

  /// Replace a pending optimistic message with the server-confirmed version.
  void _confirmPending(MessageDto dto, {int? currentUserId}) {
    final tempId = _pendingIds.removeAt(0);
    _rawMessages.add(dto);
    _messageIds.add(dto.id);

    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == tempId) {
          return ChatPresentation.toMessageUiModel(
            dto,
            currentUserId: currentUserId,
          );
        }
        return m;
      }).toList(),
    );
  }

  /// Send a message with optimistic local display.
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    // 1. Optimistic local add
    final tempId = 'pending-${_uuid.v4()}';
    _pendingIds.add(tempId);
    state = state.copyWith(
      messages: [
        ...state.messages,
        MessageUiModel(
          id: tempId,
          text: trimmedText,
          timeDisplay: _timeFormat.format(DateTime.now()),
          isFromCurrentUser: true,
          status: MessageStatus.pending,
        ),
      ],
    );

    // 2. Send via STOMP (echo confirms) or REST fallback (response confirms)
    final connState = ref.read(stompConnectionStateProvider).value;
    if (connState == StompConnectionState.connected) {
      final service = ref.read(stompServiceControllerProvider);
      service.send(
        '/app/conversation/$conversationId/send',
        body: jsonEncode({'body': trimmedText}),
      );
    } else {
      try {
        final repo = ref.read(chatRepositoryProvider);
        final dto = await repo.sendMessage(
          conversationId: conversationId,
          body: trimmedText,
        );
        if (!ref.mounted) return;
        _confirmPending(dto);
      } catch (_) {
        if (!ref.mounted) return;
        _markMessageFailed(tempId);
      }
    }

    // Invalidate inbox to reflect the new message
    if (ref.mounted) ref.invalidate(inboxProvider);
  }

  /// Retry sending a failed message.
  Future<void> retryMessage(String messageId) async {
    // Find the failed message text
    final msg = state.messages.where((m) => m.id == messageId).firstOrNull;
    if (msg == null || msg.status != MessageStatus.failed) return;

    // Set status back to pending in-place
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(status: MessageStatus.pending);
        }
        return m;
      }).toList(),
    );

    // Re-add to pending tracking
    _pendingIds.add(messageId);

    // Try sending again
    try {
      final repo = ref.read(chatRepositoryProvider);
      final dto = await repo.sendMessage(
        conversationId: conversationId,
        body: msg.text,
      );
      if (!ref.mounted) return;
      _confirmPending(dto);
    } catch (_) {
      if (!ref.mounted) return;
      _markMessageFailed(messageId);
    }

    if (ref.mounted) ref.invalidate(inboxProvider);
  }

  void _markMessageFailed(String messageId) {
    _pendingIds.remove(messageId);
    state = state.copyWith(
      messages: state.messages.map((m) {
        if (m.id == messageId) {
          return m.copyWith(status: MessageStatus.failed);
        }
        return m;
      }).toList(),
    );
  }

  /// Debounce delivery + read ACKs — batches rapid STOMP arrivals into
  /// a single ACK per ~300ms window.
  void _scheduleDebouncedAck(String peerMessageId) {
    _latestPeerMessageId = peerMessageId;
    _ackTimer?.cancel();
    _ackTimer = Timer(const Duration(milliseconds: 300), () {
      final id = _latestPeerMessageId;
      if (id == null || !ref.mounted) return;
      _sendMarkRead(id);
      _latestPeerMessageId = null;
    });
  }

  /// After initial REST load, mark-read the latest peer message if any.
  void _schedulePostLoadReadAck(int? currentUserId) {
    if (currentUserId == null || _rawMessages.isEmpty) return;

    // Find the latest peer message in the loaded batch
    String? latestPeerId;
    for (int i = _rawMessages.length - 1; i >= 0; i--) {
      if (_rawMessages[i].senderId != currentUserId) {
        latestPeerId = _rawMessages[i].id;
        break;
      }
    }

    if (latestPeerId != null) {
      _scheduleDebouncedAck(latestPeerId);
    }
  }

  void _sendAckDelivered(String lastMessageId) {
    final connState = ref.read(stompConnectionStateProvider).value;
    if (connState != StompConnectionState.connected) return;

    final service = ref.read(stompServiceControllerProvider);
    service.send(
      '/app/conversation/$conversationId/ack-delivered',
      body: jsonEncode({'lastMessageId': lastMessageId}),
    );
  }

  void _sendMarkRead(String lastMessageId) {
    // Mark-read implies delivered — send both
    _sendAckDelivered(lastMessageId);

    final connState = ref.read(stompConnectionStateProvider).value;
    if (connState != StompConnectionState.connected) return;

    final service = ref.read(stompServiceControllerProvider);
    service.send(
      '/app/conversation/$conversationId/mark-read',
      body: jsonEncode({'lastMessageId': lastMessageId}),
    );
  }

  /// Load earlier messages via REST cursor pagination.
  Future<void> loadEarlier() async {
    if (state.isLoadingEarlier || _rawMessages.isEmpty) return;

    state = state.copyWith(isLoadingEarlier: true);

    try {
      final repo = ref.read(chatRepositoryProvider);
      final oldest = _rawMessages.first;
      final olderDtos = await repo.getMessages(
        conversationId,
        before: oldest.createdAt,
        limit: 50,
      );

      if (!ref.mounted) return;

      final currentUserId = ref.read(authSessionKeyProvider);
      final newDtos = <MessageDto>[];
      for (final dto in olderDtos) {
        if (!_messageIds.contains(dto.id)) {
          newDtos.add(dto);
          _messageIds.add(dto.id);
        }
      }

      _rawMessages.insertAll(0, newDtos);

      state = state.copyWith(
        messages: [
          ...ChatPresentation.toMessageUiModels(
            newDtos,
            currentUserId: currentUserId,
          ),
          ...state.messages,
        ],
        isLoadingEarlier: false,
        hasMoreEarlier: olderDtos.length >= 50,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoadingEarlier: false);
    }
  }

  /// Force refresh from REST.
  Future<void> refresh() async {
    await _loadInitialMessages();
  }
}
