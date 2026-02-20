import 'package:freezed_annotation/freezed_annotation.dart';

part 'message_status_update_dto.freezed.dart';
part 'message_status_update_dto.g.dart';

@freezed
sealed class MessageStatusUpdateDto with _$MessageStatusUpdateDto {
  const factory MessageStatusUpdateDto({
    required String conversationId,
    required String status,
  }) = _MessageStatusUpdateDto;

  factory MessageStatusUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$MessageStatusUpdateDtoFromJson(json);
}
