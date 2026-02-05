// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CityDto _$CityDtoFromJson(Map<String, dynamic> json) => _CityDto(
  placeId: (json['placeId'] as num).toInt(),
  name: json['name'] as String,
  countryCode: json['countryCode'] as String?,
  population: (json['population'] as num?)?.toInt(),
);

Map<String, dynamic> _$CityDtoToJson(_CityDto instance) => <String, dynamic>{
  'placeId': instance.placeId,
  'name': instance.name,
  'countryCode': instance.countryCode,
  'population': instance.population,
};
