import 'package:freezed_annotation/freezed_annotation.dart';

part 'driver_profile_dto.freezed.dart';
part 'driver_profile_dto.g.dart';

@freezed
sealed class DriverProfileDto with _$DriverProfileDto {
  const factory DriverProfileDto({
    required int id,
    String? username,
    String? name,
    String? email,
    String? phoneNumber,
  }) = _DriverProfileDto;

  factory DriverProfileDto.fromJson(Map<String, dynamic> json) =>
      _$DriverProfileDtoFromJson(json);
}
