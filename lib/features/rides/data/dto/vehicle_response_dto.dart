import 'package:freezed_annotation/freezed_annotation.dart';

part 'vehicle_response_dto.freezed.dart';
part 'vehicle_response_dto.g.dart';

@freezed
sealed class VehicleResponseDto with _$VehicleResponseDto {
  const factory VehicleResponseDto({
    required int id,
    String? make,
    String? model,
    int? productionYear,
    String? color,
    String? licensePlate,
  }) = _VehicleResponseDto;

  factory VehicleResponseDto.fromJson(Map<String, dynamic> json) =>
      _$VehicleResponseDtoFromJson(json);
}
