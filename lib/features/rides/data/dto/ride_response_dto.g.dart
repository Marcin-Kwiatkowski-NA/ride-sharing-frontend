// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RideResponseDto _$RideResponseDtoFromJson(Map<String, dynamic> json) =>
    _RideResponseDto(
      id: (json['id'] as num).toInt(),
      driver: json['driver'] == null
          ? null
          : UserCardDto.fromJson(json['driver'] as Map<String, dynamic>),
      origin: LocationDto.fromJson(json['origin'] as Map<String, dynamic>),
      destination: LocationDto.fromJson(
        json['destination'] as Map<String, dynamic>,
      ),
      departureTime: DateTime.parse(json['departureTime'] as String),
      isApproximate: json['isApproximate'] as bool? ?? false,
      source:
          $enumDecodeNullable(_$RideSourceEnumMap, json['source']) ??
          RideSource.internal,
      availableSeats: (json['availableSeats'] as num).toInt(),
      seatsTaken: (json['seatsTaken'] as num?)?.toInt() ?? 0,
      pricePerSeat: (json['pricePerSeat'] as num?)?.toDouble(),
      vehicle: json['vehicle'] == null
          ? null
          : VehicleResponseDto.fromJson(
              json['vehicle'] as Map<String, dynamic>,
            ),
      rideStatus:
          $enumDecodeNullable(_$RideStatusEnumMap, json['rideStatus']) ??
          RideStatus.open,
      description: json['description'] as String?,
      contactMethods:
          (json['contactMethods'] as List<dynamic>?)
              ?.map((e) => ContactMethodDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      stops:
          (json['stops'] as List<dynamic>?)
              ?.map((e) => RideStopDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalSeats: (json['totalSeats'] as num?)?.toInt() ?? 0,
      autoApprove: json['autoApprove'] as bool? ?? true,
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
      'seatsTaken': instance.seatsTaken,
      'pricePerSeat': instance.pricePerSeat,
      'vehicle': instance.vehicle,
      'rideStatus': _$RideStatusEnumMap[instance.rideStatus]!,
      'description': instance.description,
      'contactMethods': instance.contactMethods,
      'stops': instance.stops,
      'totalSeats': instance.totalSeats,
      'autoApprove': instance.autoApprove,
    };

const _$RideSourceEnumMap = {
  RideSource.internal: 'INTERNAL',
  RideSource.facebook: 'FACEBOOK',
};

const _$RideStatusEnumMap = {
  RideStatus.open: 'OPEN',
  RideStatus.full: 'FULL',
  RideStatus.completed: 'COMPLETED',
  RideStatus.expired: 'EXPIRED',
  RideStatus.cancelled: 'CANCELLED',
  RideStatus.banned: 'BANNED',
};
