import 'package:dio/dio.dart';
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
  Future<List<ConversationDto>> getConversations({
    DateTime? since,
    CancelToken? cancelToken,
  }) async {
    await _simulateLatency();

    var conversations = _conversations.values.toList();

    // Filter by since if provided
    if (since != null) {
      conversations = conversations
          .where((c) => c.updatedAt != null && c.updatedAt!.isAfter(since))
          .toList();
    }

    // Sort by updatedAt descending (most recent first)
    conversations.sort((a, b) {
      final aTime = a.updatedAt;
      final bTime = b.updatedAt;
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
      driverName: 'Driver $driverId',
      passengerId: _currentUserId,
      passengerName: 'Current User',
      originName: 'Origin',
      destinationName: 'Destination',
    );

    _conversations[id] = conversation;
    _messages[id] = [];

    return conversation;
  }

  @override
  Future<List<MessageDto>> getMessages(
    String conversationId, {
    DateTime? before,
    DateTime? since,
    int limit = 50,
  }) async {
    await _simulateLatency();

    var messages = List<MessageDto>.from(_messages[conversationId] ?? []);

    // Filter by before/since if provided
    if (before != null) {
      messages = messages.where((m) => m.createdAt.isBefore(before)).toList();
    }
    if (since != null) {
      messages = messages.where((m) => m.createdAt.isAfter(since)).toList();
    }

    // Apply limit
    if (messages.length > limit) {
      messages = messages.sublist(messages.length - limit);
    }

    return messages;
  }

  @override
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    await _simulateLatency();

    final now = DateTime.now();
    final message = MessageDto(
      id: 'msg_${++_messageIdCounter}',
      conversationId: conversationId,
      senderId: _currentUserId,
      body: body,
      createdAt: now,
      isMine: true,
    );

    _messages.putIfAbsent(conversationId, () => []);
    _messages[conversationId]!.add(message);

    // Update conversation with last message
    final conversation = _conversations[conversationId];
    if (conversation != null) {
      _conversations[conversationId] = conversation.copyWith(
        lastMessage: message,
        updatedAt: now,
      );
    }

    return message;
  }

  Future<void> _simulateLatency() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }
}
