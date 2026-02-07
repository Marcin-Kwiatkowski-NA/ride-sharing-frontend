import 'package:freezed_annotation/freezed_annotation.dart';

part 'seat_creation_request_dto.freezed.dart';
part 'seat_creation_request_dto.g.dart';

@freezed
sealed class SeatCreationRequestDto with _$SeatCreationRequestDto {
  const factory SeatCreationRequestDto({
    required int originPlaceId,
    required int destinationPlaceId,
    required String departureTime,
    @Default(false) bool isApproximate,
    required int count,
    int? priceWillingToPay,
    String? description,
  }) = _SeatCreationRequestDto;

  factory SeatCreationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SeatCreationRequestDtoFromJson(json);
}
