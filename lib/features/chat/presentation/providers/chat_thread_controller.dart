import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/chat_repository.dart';
import '../../domain/chat_presentation.dart';
import '../../domain/message_ui_model.dart';
import 'inbox_provider.dart';

part 'chat_thread_controller.freezed.dart';
part 'chat_thread_controller.g.dart';

/// State for a chat thread.
@freezed
sealed class ChatThreadState with _$ChatThreadState {
  const factory ChatThreadState({
    @Default([]) List<MessageUiModel> messages,
    @Default(false) bool isLoading,
    Object? error,
  }) = _ChatThreadState;
}

/// Controller for a chat thread using Riverpod code generation.
@riverpod
class ChatThread extends _$ChatThread {
  @override
  ChatThreadState build(String conversationId) {
    // Trigger initial load
    Future.microtask(_loadMessages);
    return const ChatThreadState(isLoading: true);
  }

  Future<void> _loadMessages() async {
    state = const ChatThreadState(isLoading: true);

    try {
      final repository = ref.read(chatRepositoryProvider);
      final messages = await repository.getMessages(conversationId);

      state = ChatThreadState(
        messages: ChatPresentation.toMessageUiModels(messages),
      );
    } catch (e) {
      state = ChatThreadState(error: e);
    }
  }

  /// Send a message and update state.
  Future<void> sendMessage(String text) async {
    final trimmedText = text.trim();
    if (trimmedText.isEmpty) return;

    try {
      final repository = ref.read(chatRepositoryProvider);
      final message = await repository.sendMessage(
        conversationId: conversationId,
        text: trimmedText,
      );

      // Append new message to state
      state = state.copyWith(
        messages: [
          ...state.messages,
          ChatPresentation.toMessageUiModel(message),
        ],
      );

      // Invalidate inbox to reflect the new message
      ref.invalidate(inboxProvider);
    } catch (e) {
      // Could show error to user
    }
  }

  /// Refresh messages from repository.
  Future<void> refresh() async {
    await _loadMessages();
  }
}
