import 'dart:convert';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/network/stomp_connection_state.dart';
import '../../../../core/network/stomp_connection_state_provider.dart';
import '../../../../core/network/stomp_service_provider.dart';
import '../../../../core/providers/auth_session_provider.dart';
import '../../data/chat_repository.dart';
import '../../data/dto/conversation_dto.dart';
import '../../domain/chat_presentation.dart';
import '../../domain/conversation_ui_model.dart';

part 'inbox_provider.g.dart';

/// Provides the user's conversation inbox with live STOMP updates.
///
/// - Auth gate: rebuilds on login/logout (watches [authSessionKeyProvider])
/// - STOMP: listens to connection state, subscribes to /user/queue/inbox
///   for live conversation updates without rebuilding the provider
/// - REST: loads conversations on build, used as baseline
@Riverpod(keepAlive: true)
class Inbox extends _$Inbox {
  final Map<String, ConversationDto> _conversationMap = {};
  VoidCallback? _unsubscribe;

  @override
  Future<List<ConversationUiModel>> build() async {
    // Auth gate (watch — rebuild on login/logout)
    final sessionKey = ref.watch(authSessionKeyProvider);
    if (sessionKey == null) return [];

    // LISTEN (not watch) connection state — subscribe without rebuild
    ref.listen(stompConnectionStateProvider, (prev, next) {
      final connState =
          next.value ?? StompConnectionState.disconnected;
      if (connState == StompConnectionState.connected) {
        _subscribeToInbox();
      }
    });

    final cancelToken = CancelToken();
    ref.onDispose(() {
      cancelToken.cancel('disposed');
      _unsubscribe?.call();
    });

    // Initial REST load
    final repo = ref.watch(chatRepositoryProvider);
    final conversations = await repo.getConversations(
      cancelToken: cancelToken,
    );

    _conversationMap.clear();
    for (final c in conversations) {
      _conversationMap[c.id] = c;
    }

    // If already connected, subscribe immediately
    final connState = ref.read(stompConnectionStateProvider).value;
    if (connState == StompConnectionState.connected) {
      _subscribeToInbox();
    }

    return ChatPresentation.toConversationUiModels(conversations);
  }

  void _subscribeToInbox() {
    final service = ref.read(stompServiceControllerProvider);

    _unsubscribe?.call();
    _unsubscribe = service.subscribe(
      '/user/queue/inbox',
      (frame) {
        if (frame.body == null || !ref.mounted) return;
        try {
          final json = jsonDecode(frame.body!) as Map<String, dynamic>;
          final dto = ConversationDto.fromJson(json);
          _mergeConversationUpdate(dto);
        } catch (_) {
          // Ignore malformed frames
        }
      },
    );
  }

  void _mergeConversationUpdate(ConversationDto dto) {
    _conversationMap[dto.id] = dto;

    // Re-sort: most recently updated first
    final sorted = _conversationMap.values.toList()
      ..sort((a, b) {
        final aTime = a.lastMessageAt ?? DateTime(2000);
        final bTime = b.lastMessageAt ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });

    state = AsyncData(ChatPresentation.toConversationUiModels(sorted));
  }
}
