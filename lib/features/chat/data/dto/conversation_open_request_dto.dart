import 'package:freezed_annotation/freezed_annotation.dart';

part 'conversation_open_request_dto.freezed.dart';
part 'conversation_open_request_dto.g.dart';

@freezed
sealed class ConversationOpenRequestDto with _$ConversationOpenRequestDto {
  const factory ConversationOpenRequestDto({
    required String topicKey,
    required int peerUserId,
  }) = _ConversationOpenRequestDto;

  factory ConversationOpenRequestDto.fromJson(Map<String, dynamic> json) =>
      _$ConversationOpenRequestDtoFromJson(json);
}
