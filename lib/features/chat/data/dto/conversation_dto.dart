import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_dto.freezed.dart';
part 'conversation_dto.g.dart';

@freezed
sealed class ConversationDto with _$ConversationDto {
  const factory ConversationDto({
    required String id,
    required int rideId,
    required int driverId,
    required String driverName,
    String? lastMessageText,
    DateTime? lastMessageAt,
    @Default(0) int unreadCount,
  }) = _ConversationDto;

  factory ConversationDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationDtoFromJson(json);
}
