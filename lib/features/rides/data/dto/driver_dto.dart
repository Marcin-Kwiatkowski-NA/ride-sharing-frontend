import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_dto.freezed.dart';
part 'driver_dto.g.dart';

@freezed
sealed class DriverDto with _$DriverDto {
  const factory DriverDto({
    String? name,
    double? rating,
    int? completedRides,
  }) = _DriverDto;

  factory DriverDto.fromJson(Map<String, dynamic> json) =>
      _$DriverDtoFromJson(json);
}
