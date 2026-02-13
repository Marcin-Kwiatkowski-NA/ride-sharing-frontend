import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../offers/data/city_dto.dart';

part 'ride_stop_dto.freezed.dart';
part 'ride_stop_dto.g.dart';

@freezed
sealed class RideStopDto with _$RideStopDto {
  const factory RideStopDto({
    required int stopOrder,
    required CityDto city,
    DateTime? departureTime,
  }) = _RideStopDto;

  factory RideStopDto.fromJson(Map<String, dynamic> json) =>
      _$RideStopDtoFromJson(json);
}
