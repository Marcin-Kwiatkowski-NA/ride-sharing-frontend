import 'package:freezed_annotation/freezed_annotation.dart';

import 'message_dto.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

@freezed
sealed class ConversationDto with _$ConversationDto {
  const factory ConversationDto({
    required String id,
    required int rideId,
    required int driverId,
    required String driverName,
    required int passengerId,
    required String passengerName,
    required String originName,
    required String destinationName,
    MessageDto? lastMessage,
    @Default(0) int unreadCount,
    DateTime? updatedAt,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
}
