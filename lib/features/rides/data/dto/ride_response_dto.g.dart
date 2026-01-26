// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideResponseDto _$RideResponseDtoFromJson(
  Map<String, dynamic> json,
) => _RideResponseDto(
  id: (json['id'] as num).toInt(),
  driver: json['driver'] == null
      ? null
      : DriverProfileDto.fromJson(json['driver'] as Map<String, dynamic>),
  origin: CityDto.fromJson(json['origin'] as Map<String, dynamic>),
  destination: CityDto.fromJson(json['destination'] as Map<String, dynamic>),
  departureTime: DateTime.parse(json['departureTime'] as String),
  isApproximate: json['isApproximate'] as bool? ?? false,
  source:
      $enumDecodeNullable(_$RideSourceEnumMap, json['source']) ??
      RideSource.internal,
  availableSeats: (json['availableSeats'] as num).toInt(),
  pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
  vehicle: json['vehicle'] == null
      ? null
      : VehicleResponseDto.fromJson(json['vehicle'] as Map<String, dynamic>),
  rideStatus:
      $enumDecodeNullable(_$RideStatusEnumMap, json['rideStatus']) ??
      RideStatus.open,
  lastModified: json['lastModified'] == null
      ? null
      : DateTime.parse(json['lastModified'] as String),
  passengers:
      (json['passengers'] as List<dynamic>?)
          ?.map((e) => DriverProfileDto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  sourceUrl: json['sourceUrl'] as String?,
);

Map<String, dynamic> _$RideResponseDtoToJson(_RideResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'driver': instance.driver,
      'origin': instance.origin,
      'destination': instance.destination,
      'departureTime': instance.departureTime.toIso8601String(),
      'isApproximate': instance.isApproximate,
      'source': _$RideSourceEnumMap[instance.source]!,
      'availableSeats': instance.availableSeats,
      'pricePerSeat': instance.pricePerSeat,
      'vehicle': instance.vehicle,
      'rideStatus': _$RideStatusEnumMap[instance.rideStatus]!,
      'lastModified': instance.lastModified?.toIso8601String(),
      'passengers': instance.passengers,
      'sourceUrl': instance.sourceUrl,
    };

const _$RideSourceEnumMap = {
  RideSource.internal: 'INTERNAL',
  RideSource.facebook: 'FACEBOOK',
};

const _$RideStatusEnumMap = {
  RideStatus.open: 'OPEN',
  RideStatus.full: 'FULL',
  RideStatus.completed: 'COMPLETED',
  RideStatus.cancelled: 'CANCELLED',
};
