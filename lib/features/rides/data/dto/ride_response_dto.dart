import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../offers/data/contact_method_dto.dart';
import '../../../offers/data/location_dto.dart';
import '../../../offers/data/offer_enums.dart';
import 'ride_enums.dart';
import 'ride_stop_dto.dart';
import 'user_card_dto.dart';
import 'vehicle_response_dto.dart';

part 'ride_response_dto.freezed.dart';
part 'ride_response_dto.g.dart';

@freezed
sealed class RideResponseDto with _$RideResponseDto {
  const factory RideResponseDto({
    required int id,
    UserCardDto? driver,
    required LocationDto origin,
    required LocationDto destination,
    required DateTime departureTime,
    @Default(false) bool isApproximate,
    @Default(RideSource.internal) RideSource source,
    required int availableSeats,
    @Default(0) int seatsTaken,
    double? pricePerSeat,
    VehicleResponseDto? vehicle,
    @Default(RideStatus.open) RideStatus rideStatus,
    String? description,
    @Default([]) List<ContactMethodDto> contactMethods,
    @Default([]) List<RideStopDto> stops,
    @Default(0) int totalSeats,
    @Default(true) bool autoApprove,
  }) = _RideResponseDto;

  factory RideResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RideResponseDtoFromJson(json);
}
