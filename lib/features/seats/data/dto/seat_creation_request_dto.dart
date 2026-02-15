import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/locations/data/location_ref_dto.dart';

part 'seat_creation_request_dto.freezed.dart';
part 'seat_creation_request_dto.g.dart';

@freezed
sealed class SeatCreationRequestDto with _$SeatCreationRequestDto {
  const factory SeatCreationRequestDto({
    required LocationRefDto origin,
    required LocationRefDto destination,
    required String departureTime,
    @Default(false) bool isApproximate,
    required int count,
    int? priceWillingToPay,
    String? description,
  }) = _SeatCreationRequestDto;

  factory SeatCreationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$SeatCreationRequestDtoFromJson(json);
}
