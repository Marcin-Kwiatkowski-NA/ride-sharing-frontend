import 'package:dio/dio.dart';

import 'chat_repository.dart';
import 'dto/conversation_dto.dart';
import 'dto/message_dto.dart';

/// API implementation of ChatRepository using /conversations endpoints.
class ApiChatRepository implements ChatRepository {
  final Dio _dio;

  ApiChatRepository(this._dio);

  @override
  Future<List<ConversationDto>> getConversations({DateTime? since}) async {
    final queryParams = <String, dynamic>{};
    if (since != null) {
      queryParams['since'] = since.toUtc().toIso8601String();
    }

    final response = await _dio.get<List<dynamic>>(
      '/conversations',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    return (response.data ?? [])
        .map((json) => ConversationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ConversationDto> initConversation({
    required int rideId,
    required int driverId,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/conversations/init',
      data: {
        'rideId': rideId,
        'driverId': driverId,
      },
    );

    return ConversationDto.fromJson(response.data!);
  }

  @override
  Future<List<MessageDto>> getMessages(
    String conversationId, {
    DateTime? before,
    DateTime? since,
    int limit = 50,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
    };
    if (before != null) {
      queryParams['before'] = before.toUtc().toIso8601String();
    }
    if (since != null) {
      queryParams['since'] = since.toUtc().toIso8601String();
    }

    final response = await _dio.get<List<dynamic>>(
      '/conversations/$conversationId/messages',
      queryParameters: queryParams,
    );

    return (response.data ?? [])
        .map((json) => MessageDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MessageDto> sendMessage({
    required String conversationId,
    required String body,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      data: {'body': body},
    );

    return MessageDto.fromJson(response.data!);
  }
}
