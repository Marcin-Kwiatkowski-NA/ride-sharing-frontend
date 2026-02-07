import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blablafront/core/providers/auth_session_provider.dart';
import 'package:blablafront/features/chat/presentation/providers/inbox_provider.dart';
import 'package:blablafront/features/chat/data/chat_repository.dart';
import 'package:blablafront/features/chat/data/dto/conversation_dto.dart';
import 'package:blablafront/features/chat/data/dto/conversation_open_response_dto.dart';
import 'package:blablafront/features/chat/data/dto/message_dto.dart';
import 'package:blablafront/features/chat/data/dto/peer_user_dto.dart';

/// Mock implementation of ChatRepository for testing
class MockChatRepository implements ChatRepository {
  final List<ConversationDto> mockConversations;
  int getConversationsCallCount = 0;

  MockChatRepository({this.mockConversations = const []});

  @override
  Future<List<ConversationDto>> getConversations({
    DateTime? since,
    CancelToken? cancelToken,
  }) async {
    getConversationsCallCount++;
    return mockConversations;
  }

  @override
  Future<ConversationOpenResponseDto> openConversation({
    required String topicKey,
    required int peerUserId,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<List<MessageDto>> getMessages(
    String conversationId, {
    DateTime? before,
    DateTime? since,
    int limit = 50,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    throw UnimplementedError();
  }
}

void main() {
  group('inboxProvider', () {
    test('returns empty list when session key is null (no API call)', () async {
      final mockRepository = MockChatRepository();

      final container = ProviderContainer(
        overrides: [
          authSessionKeyProvider.overrideWithValue(null),
          chatRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(inboxProvider.future);

      expect(result, isEmpty);
      expect(mockRepository.getConversationsCallCount, 0);
    });

    test('fetches from API when session key is present', () async {
      final mockRepository = MockChatRepository(
        mockConversations: [
          const ConversationDto(
            id: 'conv-1',
            topicKey: 'offer:r-1',
            peerUser: PeerUserDto(id: 456, displayName: 'Driver'),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          authSessionKeyProvider.overrideWithValue(123),
          chatRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(inboxProvider.future);

      expect(result, hasLength(1));
      expect(result.first.id, 'conv-1');
      expect(mockRepository.getConversationsCallCount, 1);
    });

    test('returns conversations transformed to UI models', () async {
      final mockRepository = MockChatRepository(
        mockConversations: [
          const ConversationDto(
            id: 'conv-1',
            topicKey: 'offer:r-1',
            peerUser: PeerUserDto(id: 456, displayName: 'John'),
            unreadCount: 3,
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          authSessionKeyProvider.overrideWithValue(123),
          chatRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(inboxProvider.future);

      expect(result, hasLength(1));
      final conversation = result.first;
      expect(conversation.id, 'conv-1');
      expect(conversation.peerUserName, 'John');
      expect(conversation.unreadCount, 3);
    });

    test('handles multiple conversations', () async {
      final mockRepository = MockChatRepository(
        mockConversations: [
          const ConversationDto(
            id: 'conv-1',
            topicKey: 'offer:r-1',
            peerUser: PeerUserDto(id: 100, displayName: 'User A'),
          ),
          const ConversationDto(
            id: 'conv-2',
            topicKey: 'offer:r-2',
            peerUser: PeerUserDto(id: 200, displayName: 'User B'),
          ),
        ],
      );

      final container = ProviderContainer(
        overrides: [
          authSessionKeyProvider.overrideWithValue(123),
          chatRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(inboxProvider.future);

      expect(result, hasLength(2));
      expect(result[0].id, 'conv-1');
      expect(result[1].id, 'conv-2');
    });
  });
}
