import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blablafront/core/network/dio_provider.dart';
import 'api_chat_repository.dart';
import 'dto/conversation_dto.dart';
import 'dto/message_dto.dart';

part 'chat_repository.g.dart';

/// Repository interface for chat operations.
abstract interface class ChatRepository {
  /// Get all conversations for the current user, sorted by most recent.
  Future<List<ConversationDto>> getConversations({
    DateTime? since,
    CancelToken? cancelToken,
  });

  /// Get existing conversation or create a new one for a ride with a driver.
  /// POST /conversations/init
  Future<ConversationDto> getOrCreateConversation({
    required int rideId,
    required int driverId,
  });

  /// Get messages for a conversation with optional cursor-based pagination.
  /// GET /conversations/{conversationId}/messages
  Future<List<MessageDto>> getMessages(
    String conversationId, {
    DateTime? before,
    DateTime? since,
    int limit = 50,
  });

  /// Send a message in a conversation.
  /// POST /conversations/{conversationId}/messages
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String body,
  });
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ApiChatRepository(dio);
}
