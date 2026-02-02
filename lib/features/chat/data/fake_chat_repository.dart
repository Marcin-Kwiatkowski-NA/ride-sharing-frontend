import 'dto/conversation_dto.dart';
import 'dto/message_dto.dart';
import 'chat_repository.dart';

/// In-memory fake implementation of ChatRepository.
///
/// Uses static maps for data persistence across widget rebuilds.
class FakeChatRepository implements ChatRepository {
  // Static storage to persist across instances
  static final Map<String, ConversationDto> _conversations = {};
  static final Map<String, List<MessageDto>> _messages = {};
  static int _messageIdCounter = 0;

  // Current user ID (simulated)
  static const int _currentUserId = 1;

  @override
  Future<List<ConversationDto>> getConversations() async {
    await _simulateLatency();

    final conversations = _conversations.values.toList();
    // Sort by lastMessageAt descending (most recent first)
    conversations.sort((a, b) {
      final aTime = a.lastMessageAt;
      final bTime = b.lastMessageAt;
      if (aTime == null && bTime == null) return 0;
      if (aTime == null) return 1;
      if (bTime == null) return -1;
      return bTime.compareTo(aTime);
    });

    return conversations;
  }

  @override
  Future<ConversationDto> getOrCreateConversation({
    required int rideId,
    required int driverId,
    required String driverName,
  }) async {
    await _simulateLatency();

    final id = 'ride_${rideId}_driver_$driverId';

    if (_conversations.containsKey(id)) {
      return _conversations[id]!;
    }

    final conversation = ConversationDto(
      id: id,
      rideId: rideId,
      driverId: driverId,
      driverName: driverName,
    );

    _conversations[id] = conversation;
    _messages[id] = [];

    return conversation;
  }

  @override
  Future<List<MessageDto>> getMessages(String conversationId) async {
    await _simulateLatency();

    return List.from(_messages[conversationId] ?? []);
  }

  @override
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String text,
  }) async {
    await _simulateLatency();

    final message = MessageDto(
      id: 'msg_${++_messageIdCounter}',
      conversationId: conversationId,
      senderId: _currentUserId,
      text: text,
      sentAt: DateTime.now(),
      isFromCurrentUser: true,
    );

    _messages.putIfAbsent(conversationId, () => []);
    _messages[conversationId]!.add(message);

    // Update conversation with last message
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(
        lastMessageText: text,
        lastMessageAt: message.sentAt,
      );
    }

    return message;
  }

  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
