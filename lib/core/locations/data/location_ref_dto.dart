import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_ref_dto.freezed.dart';
part 'location_ref_dto.g.dart';

/// Strongly-typed DTO matching the backend LocationRef contract.
///
/// Used in ride/seat creation requests to send full location data.
@freezed
sealed class LocationRefDto with _$LocationRefDto {
  const factory LocationRefDto({
    required int osmId,
    required String name,
    required String lang,
    required double latitude,
    required double longitude,
    String? countryCode,
    String? country,
    String? state,
    String? county,
    String? city,
    String? postCode,
    String? type,
    String? osmKey,
    String? osmValue,
  }) = _LocationRefDto;

  factory LocationRefDto.fromJson(Map<String, dynamic> json) =>
      _$LocationRefDtoFromJson(json);
}
