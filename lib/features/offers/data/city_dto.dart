import 'package:freezed_annotation/freezed_annotation.dart';

part 'city_dto.freezed.dart';
part 'city_dto.g.dart';

@freezed
sealed class CityDto with _$CityDto {
  const factory CityDto({
    required int placeId,
    required String name,
    String? countryCode,
    int? population,
  }) = _CityDto;

  factory CityDto.fromJson(Map<String, dynamic> json) =>
      _$CityDtoFromJson(json);
}
