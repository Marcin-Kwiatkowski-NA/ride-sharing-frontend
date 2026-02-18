import 'package:freezed_annotation/freezed_annotation.dart';

part 'stomp_error_dto.freezed.dart';
part 'stomp_error_dto.g.dart';

/// Error received from the backend via STOMP /user/queue/errors
/// or from STOMP/WebSocket protocol-level errors.
@freezed
sealed class StompErrorDto with _$StompErrorDto {
  const factory StompErrorDto({
    required String code,
    required String message,
    String? conversationId,
  }) = _StompErrorDto;

  factory StompErrorDto.fromJson(Map<String, dynamic> json) =>
      _$StompErrorDtoFromJson(json);
}
