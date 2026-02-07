import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_open_response_dto.freezed.dart';
part 'conversation_open_response_dto.g.dart';

@freezed
sealed class ConversationOpenResponseDto with _$ConversationOpenResponseDto {
  const factory ConversationOpenResponseDto({
    @JsonKey(name: 'id') required String conversationId,
    @Default(false) bool created,
  }) = _ConversationOpenResponseDto;

  factory ConversationOpenResponseDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationOpenResponseDtoFromJson(json);
}
