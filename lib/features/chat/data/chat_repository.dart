import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'dto/conversation_dto.dart';
import 'dto/message_dto.dart';
import 'fake_chat_repository.dart';

part 'chat_repository.g.dart';

/// Repository interface for chat operations.
abstract interface class ChatRepository {
  /// Get all conversations for the current user, sorted by most recent.
  Future<List<ConversationDto>> getConversations();

  /// Get or create a conversation for a ride with a driver.
  Future<ConversationDto> getOrCreateConversation({
    required int rideId,
    required int driverId,
    required String driverName,
  });

  /// Get all messages for a conversation.
  Future<List<MessageDto>> getMessages(String conversationId);

  /// Send a message in a conversation.
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String text,
  });
}

@Riverpod(keepAlive: true)
ChatRepository chatRepository(Ref ref) {
  return FakeChatRepository();
}
