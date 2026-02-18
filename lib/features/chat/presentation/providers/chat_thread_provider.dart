import 'dart:convert';
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
import '../../domain/chat_presentation.dart';
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

  @override
  ChatThreadState build(String conversationId) {
    // LISTEN (not watch) connection state — no rebuild, just react
    ref.listen(stompConnectionStateProvider, (prev, next) {
      final connState =
          next.value ?? StompConnectionState.disconnected;
      if (connState == StompConnectionState.connected) {
        _subscribeToStomp();
        _catchUpMessages();
      }
    });

    ref.onDispose(() {
      _unsubscribe?.call();
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

      _rawMessages.clear();
      _messageIds.clear();
      for (final dto in dtos) {
        _rawMessages.add(dto);
        _messageIds.add(dto.id);
      }

      state = ChatThreadState(
        messages: ChatPresentation.toMessageUiModels(dtos),
        hasMoreEarlier: dtos.length >= 50,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = ChatThreadState(error: e);
    }

    // Register subscription intent AFTER the try/catch — a subscription
    // failure must not overwrite successfully loaded messages.
    // StompService.subscribe() handles both connected (immediate) and
    // disconnected (tracked for auto-subscribe on connect) cases.
    if (ref.mounted) _subscribeToStomp();
  }

  void _subscribeToStomp() {
    final service = ref.read(stompServiceControllerProvider);
    final currentUserId = ref.read(authSessionKeyProvider);

    // Prevent duplicate subscriptions
    _unsubscribe?.call();
    _unsubscribe = service.subscribe(
      '/topic/conversation/$conversationId',
      (frame) {
        if (frame.body == null || !ref.mounted) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final dto = MessageDto.fromJson(json);
          _mergeIncomingMessage(dto, currentUserId: currentUserId);
        } catch (_) {
          // Ignore malformed frames
        }
      },
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
  ///
  /// The message appears immediately. STOMP echo (or REST response on
  /// fallback) replaces the pending placeholder via [_confirmPending].
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
        // Could surface error / mark message as failed
      }
    }

    // Invalidate inbox to reflect the new message
    if (ref.mounted) ref.invalidate(inboxProvider);
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
          ...ChatPresentation.toMessageUiModels(newDtos),
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
