// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_profile_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DriverProfileDto _$DriverProfileDtoFromJson(Map<String, dynamic> json) =>
    _DriverProfileDto(
      id: (json['id'] as num).toInt(),
      username: json['username'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
    );

Map<String, dynamic> _$DriverProfileDtoToJson(_DriverProfileDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'name': instance.name,
      'email': instance.email,
      'phoneNumber': instance.phoneNumber,
    };
