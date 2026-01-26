// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vehicle_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_VehicleResponseDto _$VehicleResponseDtoFromJson(Map<String, dynamic> json) =>
    _VehicleResponseDto(
      id: (json['id'] as num).toInt(),
      make: json['make'] as String?,
      model: json['model'] as String?,
      productionYear: (json['productionYear'] as num?)?.toInt(),
      color: json['color'] as String?,
      licensePlate: json['licensePlate'] as String?,
    );

Map<String, dynamic> _$VehicleResponseDtoToJson(_VehicleResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'make': instance.make,
      'model': instance.model,
      'productionYear': instance.productionYear,
      'color': instance.color,
      'licensePlate': instance.licensePlate,
    };
