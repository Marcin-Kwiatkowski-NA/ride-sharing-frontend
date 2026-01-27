import 'package:freezed_annotation/freezed_annotation.dart';

import 'city_dto.dart';
import 'contact_method_dto.dart';
import 'driver_dto.dart';
import 'ride_enums.dart';
import 'vehicle_response_dto.dart';

part 'ride_response_dto.freezed.dart';
part 'ride_response_dto.g.dart';

@freezed
sealed class RideResponseDto with _$RideResponseDto {
  const factory RideResponseDto({
    required int id,
    DriverDto? driver,
    required CityDto origin,
    required CityDto destination,
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
  }) = _RideResponseDto;

  factory RideResponseDto.fromJson(Map<String, dynamic> json) =>
      _$RideResponseDtoFromJson(json);
}
