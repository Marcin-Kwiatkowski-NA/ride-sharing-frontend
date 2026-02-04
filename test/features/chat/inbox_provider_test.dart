import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blablafront/core/providers/auth_session_provider.dart';
import 'package:blablafront/features/chat/presentation/providers/inbox_provider.dart';
import 'package:blablafront/features/chat/data/chat_repository.dart';
import 'package:blablafront/features/chat/data/dto/conversation_dto.dart';
import 'package:blablafront/features/chat/data/dto/message_dto.dart';

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
  Future<ConversationDto> getOrCreateConversation({
    required int rideId,
    required int driverId,
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
            rideId: 1,
            driverId: 456,
            driverName: 'Driver',
            passengerId: 123,
            passengerName: 'Passenger',
            originName: 'A',
            destinationName: 'B',
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
            rideId: 1,
            driverId: 456,
            driverName: 'John Driver',
            passengerId: 123,
            passengerName: 'Jane Passenger',
            originName: 'Paris',
            destinationName: 'Lyon',
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
      expect(conversation.driverName, 'John Driver');
      expect(conversation.unreadCount, 3);
    });

    test('handles multiple conversations', () async {
      final mockRepository = MockChatRepository(
        mockConversations: [
          const ConversationDto(
            id: 'conv-1',
            rideId: 1,
            driverId: 100,
            driverName: 'Driver A',
            passengerId: 123,
            passengerName: 'Passenger',
            originName: 'Paris',
            destinationName: 'Lyon',
          ),
          const ConversationDto(
            id: 'conv-2',
            rideId: 2,
            driverId: 200,
            driverName: 'Driver B',
            passengerId: 123,
            passengerName: 'Passenger',
            originName: 'Berlin',
            destinationName: 'Munich',
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
