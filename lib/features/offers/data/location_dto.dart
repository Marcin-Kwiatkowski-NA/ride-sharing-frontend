import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_dto.freezed.dart';
part 'location_dto.g.dart';

/// Response DTO for locations returned by the backend.
///
/// Used in ride/seat response DTOs.
@freezed
sealed class LocationDto with _$LocationDto {
  const factory LocationDto({
    required int osmId,
    required String name,
    String? country,
    String? countryCode,
    double? latitude,
    double? longitude,
    String? type,
  }) = _LocationDto;

  factory LocationDto.fromJson(Map<String, dynamic> json) =>
      _$LocationDtoFromJson(json);
}
