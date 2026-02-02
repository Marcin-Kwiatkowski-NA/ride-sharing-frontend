import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_dto.freezed.dart';
part 'message_dto.g.dart';

@freezed
sealed class MessageDto with _$MessageDto {
  const factory MessageDto({
    required String id,
    required String conversationId,
    required int senderId,
    required String text,
    required DateTime sentAt,
    required bool isFromCurrentUser,
  }) = _MessageDto;

  factory MessageDto.fromJson(Map<String, dynamic> json) =>
      _$MessageDtoFromJson(json);
}
