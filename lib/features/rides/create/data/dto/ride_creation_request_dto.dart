import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../core/locations/data/location_ref_dto.dart';
import 'intermediate_stop_dto.dart';

part 'ride_creation_request_dto.freezed.dart';
part 'ride_creation_request_dto.g.dart';

/// DTO for creating a new ride, matching backend RideCreationDto.
///
/// Uses nested LocationRefDto objects for origin/destination and
/// a unified intermediateStops list.
@freezed
sealed class RideCreationRequestDto with _$RideCreationRequestDto {
  const factory RideCreationRequestDto({
    required LocationRefDto origin,
    required LocationRefDto destination,
    required String departureTime, // "yyyy-MM-ddTHH:mm:ss" (no timezone)
    @Default(false) bool isApproximate,
    required int availableSeats, // 1-8
    int? pricePerSeat, // 1-999, null = negotiable
    int? vehicleId,
    String? description, // max 500, null if empty
    List<IntermediateStopDto>? intermediateStops,
    @Default(true) bool autoApprove,
  }) = _RideCreationRequestDto;

  factory RideCreationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RideCreationRequestDtoFromJson(json);
}
