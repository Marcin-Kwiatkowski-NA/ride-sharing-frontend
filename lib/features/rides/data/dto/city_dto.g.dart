// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CityDto _$CityDtoFromJson(Map<String, dynamic> json) => _CityDto(
  osmId: (json['osmId'] as num?)?.toInt(),
  name: json['name'] as String,
);

Map<String, dynamic> _$CityDtoToJson(_CityDto instance) => <String, dynamic>{
  'osmId': instance.osmId,
  'name': instance.name,
};
