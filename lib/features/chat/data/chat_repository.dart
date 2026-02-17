import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:vamigo/core/network/dio_provider.dart';
import 'api_chat_repository.dart';
import 'dto/conversation_dto.dart';
import 'dto/conversation_open_response_dto.dart';
import 'dto/message_dto.dart';

part 'chat_repository.g.dart';

/// Repository interface for chat operations.
abstract interface class ChatRepository {
  /// Get all conversations for the current user, sorted by most recent.
  Future<List<ConversationDto>> getConversations({
    DateTime? since,
    CancelToken? cancelToken,
  });

  /// Open or create a conversation by topic key and peer user.
  /// POST /conversations/open
  Future<ConversationOpenResponseDto> openConversation({
    required String topicKey,
    required int peerUserId,
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
  final dio = ref.watch(apiDioProvider);
  return ApiChatRepository(dio);
}
