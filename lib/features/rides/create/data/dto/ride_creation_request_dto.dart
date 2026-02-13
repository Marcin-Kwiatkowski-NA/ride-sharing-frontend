import 'package:freezed_annotation/freezed_annotation.dart';

part 'ride_creation_request_dto.freezed.dart';
part 'ride_creation_request_dto.g.dart';

/// DTO for creating a new ride, matching backend RideCreationDto.
///
/// Uses flat placeId fields instead of nested city objects.
@freezed
sealed class RideCreationRequestDto with _$RideCreationRequestDto {
  const factory RideCreationRequestDto({
    required int driverId,
    required int originPlaceId,
    required int destinationPlaceId,
    required String departureTime, // "yyyy-MM-ddTHH:mm:ss" (no timezone)
    @Default(false) bool isApproximate,
    required int availableSeats, // 1-8
    int? pricePerSeat, // 1-999, null = negotiable
    int? vehicleId,
    String? description, // max 500, null if empty
    List<int>? intermediateStopPlaceIds,
    List<String>? intermediateStopDepartureTimes,
  }) = _RideCreationRequestDto;

  factory RideCreationRequestDto.fromJson(Map<String, dynamic> json) =>
      _$RideCreationRequestDtoFromJson(json);
}
