// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ride_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RideResponseDto {

 int get id; DriverProfileDto? get driver; CityDto get origin; CityDto get destination; DateTime get departureTime; bool get isApproximate; RideSource get source; int get availableSeats; double? get pricePerSeat; VehicleResponseDto? get vehicle; RideStatus get rideStatus; DateTime? get lastModified; List<DriverProfileDto> get passengers; String? get sourceUrl;
/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RideResponseDtoCopyWith<RideResponseDto> get copyWith => _$RideResponseDtoCopyWithImpl<RideResponseDto>(this as RideResponseDto, _$identity);

  /// Serializes this RideResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RideResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.isApproximate, isApproximate) || other.isApproximate == isApproximate)&&(identical(other.source, source) || other.source == source)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.rideStatus, rideStatus) || other.rideStatus == rideStatus)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&const DeepCollectionEquality().equals(other.passengers, passengers)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driver,origin,destination,departureTime,isApproximate,source,availableSeats,pricePerSeat,vehicle,rideStatus,lastModified,const DeepCollectionEquality().hash(passengers),sourceUrl);

@override
String toString() {
  return 'RideResponseDto(id: $id, driver: $driver, origin: $origin, destination: $destination, departureTime: $departureTime, isApproximate: $isApproximate, source: $source, availableSeats: $availableSeats, pricePerSeat: $pricePerSeat, vehicle: $vehicle, rideStatus: $rideStatus, lastModified: $lastModified, passengers: $passengers, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class $RideResponseDtoCopyWith<$Res>  {
  factory $RideResponseDtoCopyWith(RideResponseDto value, $Res Function(RideResponseDto) _then) = _$RideResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, DriverProfileDto? driver, CityDto origin, CityDto destination, DateTime departureTime, bool isApproximate, RideSource source, int availableSeats, double? pricePerSeat, VehicleResponseDto? vehicle, RideStatus rideStatus, DateTime? lastModified, List<DriverProfileDto> passengers, String? sourceUrl
});


$DriverProfileDtoCopyWith<$Res>? get driver;$CityDtoCopyWith<$Res> get origin;$CityDtoCopyWith<$Res> get destination;$VehicleResponseDtoCopyWith<$Res>? get vehicle;

}
/// @nodoc
class _$RideResponseDtoCopyWithImpl<$Res>
    implements $RideResponseDtoCopyWith<$Res> {
  _$RideResponseDtoCopyWithImpl(this._self, this._then);

  final RideResponseDto _self;
  final $Res Function(RideResponseDto) _then;

/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? driver = freezed,Object? origin = null,Object? destination = null,Object? departureTime = null,Object? isApproximate = null,Object? source = null,Object? availableSeats = null,Object? pricePerSeat = freezed,Object? vehicle = freezed,Object? rideStatus = null,Object? lastModified = freezed,Object? passengers = null,Object? sourceUrl = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverProfileDto?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as CityDto,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as CityDto,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,isApproximate: null == isApproximate ? _self.isApproximate : isApproximate // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RideSource,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,pricePerSeat: freezed == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleResponseDto?,rideStatus: null == rideStatus ? _self.rideStatus : rideStatus // ignore: cast_nullable_to_non_nullable
as RideStatus,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,passengers: null == passengers ? _self.passengers : passengers // ignore: cast_nullable_to_non_nullable
as List<DriverProfileDto>,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileDtoCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverProfileDtoCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityDtoCopyWith<$Res> get origin {
  
  return $CityDtoCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityDtoCopyWith<$Res> get destination {
  
  return $CityDtoCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleResponseDtoCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleResponseDtoCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}


/// Adds pattern-matching-related methods to [RideResponseDto].
extension RideResponseDtoPatterns on RideResponseDto {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RideResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RideResponseDto() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RideResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _RideResponseDto():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RideResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _RideResponseDto() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  DriverProfileDto? driver,  CityDto origin,  CityDto destination,  DateTime departureTime,  bool isApproximate,  RideSource source,  int availableSeats,  double? pricePerSeat,  VehicleResponseDto? vehicle,  RideStatus rideStatus,  DateTime? lastModified,  List<DriverProfileDto> passengers,  String? sourceUrl)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RideResponseDto() when $default != null:
return $default(_that.id,_that.driver,_that.origin,_that.destination,_that.departureTime,_that.isApproximate,_that.source,_that.availableSeats,_that.pricePerSeat,_that.vehicle,_that.rideStatus,_that.lastModified,_that.passengers,_that.sourceUrl);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  DriverProfileDto? driver,  CityDto origin,  CityDto destination,  DateTime departureTime,  bool isApproximate,  RideSource source,  int availableSeats,  double? pricePerSeat,  VehicleResponseDto? vehicle,  RideStatus rideStatus,  DateTime? lastModified,  List<DriverProfileDto> passengers,  String? sourceUrl)  $default,) {final _that = this;
switch (_that) {
case _RideResponseDto():
return $default(_that.id,_that.driver,_that.origin,_that.destination,_that.departureTime,_that.isApproximate,_that.source,_that.availableSeats,_that.pricePerSeat,_that.vehicle,_that.rideStatus,_that.lastModified,_that.passengers,_that.sourceUrl);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  DriverProfileDto? driver,  CityDto origin,  CityDto destination,  DateTime departureTime,  bool isApproximate,  RideSource source,  int availableSeats,  double? pricePerSeat,  VehicleResponseDto? vehicle,  RideStatus rideStatus,  DateTime? lastModified,  List<DriverProfileDto> passengers,  String? sourceUrl)?  $default,) {final _that = this;
switch (_that) {
case _RideResponseDto() when $default != null:
return $default(_that.id,_that.driver,_that.origin,_that.destination,_that.departureTime,_that.isApproximate,_that.source,_that.availableSeats,_that.pricePerSeat,_that.vehicle,_that.rideStatus,_that.lastModified,_that.passengers,_that.sourceUrl);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RideResponseDto implements RideResponseDto {
  const _RideResponseDto({required this.id, this.driver, required this.origin, required this.destination, required this.departureTime, this.isApproximate = false, this.source = RideSource.internal, required this.availableSeats, this.pricePerSeat, this.vehicle, this.rideStatus = RideStatus.open, this.lastModified, final  List<DriverProfileDto> passengers = const [], this.sourceUrl}): _passengers = passengers;
  factory _RideResponseDto.fromJson(Map<String, dynamic> json) => _$RideResponseDtoFromJson(json);

@override final  int id;
@override final  DriverProfileDto? driver;
@override final  CityDto origin;
@override final  CityDto destination;
@override final  DateTime departureTime;
@override@JsonKey() final  bool isApproximate;
@override@JsonKey() final  RideSource source;
@override final  int availableSeats;
@override final  double? pricePerSeat;
@override final  VehicleResponseDto? vehicle;
@override@JsonKey() final  RideStatus rideStatus;
@override final  DateTime? lastModified;
 final  List<DriverProfileDto> _passengers;
@override@JsonKey() List<DriverProfileDto> get passengers {
  if (_passengers is EqualUnmodifiableListView) return _passengers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_passengers);
}

@override final  String? sourceUrl;

/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RideResponseDtoCopyWith<_RideResponseDto> get copyWith => __$RideResponseDtoCopyWithImpl<_RideResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RideResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RideResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.driver, driver) || other.driver == driver)&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureTime, departureTime) || other.departureTime == departureTime)&&(identical(other.isApproximate, isApproximate) || other.isApproximate == isApproximate)&&(identical(other.source, source) || other.source == source)&&(identical(other.availableSeats, availableSeats) || other.availableSeats == availableSeats)&&(identical(other.pricePerSeat, pricePerSeat) || other.pricePerSeat == pricePerSeat)&&(identical(other.vehicle, vehicle) || other.vehicle == vehicle)&&(identical(other.rideStatus, rideStatus) || other.rideStatus == rideStatus)&&(identical(other.lastModified, lastModified) || other.lastModified == lastModified)&&const DeepCollectionEquality().equals(other._passengers, _passengers)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,driver,origin,destination,departureTime,isApproximate,source,availableSeats,pricePerSeat,vehicle,rideStatus,lastModified,const DeepCollectionEquality().hash(_passengers),sourceUrl);

@override
String toString() {
  return 'RideResponseDto(id: $id, driver: $driver, origin: $origin, destination: $destination, departureTime: $departureTime, isApproximate: $isApproximate, source: $source, availableSeats: $availableSeats, pricePerSeat: $pricePerSeat, vehicle: $vehicle, rideStatus: $rideStatus, lastModified: $lastModified, passengers: $passengers, sourceUrl: $sourceUrl)';
}


}

/// @nodoc
abstract mixin class _$RideResponseDtoCopyWith<$Res> implements $RideResponseDtoCopyWith<$Res> {
  factory _$RideResponseDtoCopyWith(_RideResponseDto value, $Res Function(_RideResponseDto) _then) = __$RideResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, DriverProfileDto? driver, CityDto origin, CityDto destination, DateTime departureTime, bool isApproximate, RideSource source, int availableSeats, double? pricePerSeat, VehicleResponseDto? vehicle, RideStatus rideStatus, DateTime? lastModified, List<DriverProfileDto> passengers, String? sourceUrl
});


@override $DriverProfileDtoCopyWith<$Res>? get driver;@override $CityDtoCopyWith<$Res> get origin;@override $CityDtoCopyWith<$Res> get destination;@override $VehicleResponseDtoCopyWith<$Res>? get vehicle;

}
/// @nodoc
class __$RideResponseDtoCopyWithImpl<$Res>
    implements _$RideResponseDtoCopyWith<$Res> {
  __$RideResponseDtoCopyWithImpl(this._self, this._then);

  final _RideResponseDto _self;
  final $Res Function(_RideResponseDto) _then;

/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? driver = freezed,Object? origin = null,Object? destination = null,Object? departureTime = null,Object? isApproximate = null,Object? source = null,Object? availableSeats = null,Object? pricePerSeat = freezed,Object? vehicle = freezed,Object? rideStatus = null,Object? lastModified = freezed,Object? passengers = null,Object? sourceUrl = freezed,}) {
  return _then(_RideResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,driver: freezed == driver ? _self.driver : driver // ignore: cast_nullable_to_non_nullable
as DriverProfileDto?,origin: null == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as CityDto,destination: null == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as CityDto,departureTime: null == departureTime ? _self.departureTime : departureTime // ignore: cast_nullable_to_non_nullable
as DateTime,isApproximate: null == isApproximate ? _self.isApproximate : isApproximate // ignore: cast_nullable_to_non_nullable
as bool,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as RideSource,availableSeats: null == availableSeats ? _self.availableSeats : availableSeats // ignore: cast_nullable_to_non_nullable
as int,pricePerSeat: freezed == pricePerSeat ? _self.pricePerSeat : pricePerSeat // ignore: cast_nullable_to_non_nullable
as double?,vehicle: freezed == vehicle ? _self.vehicle : vehicle // ignore: cast_nullable_to_non_nullable
as VehicleResponseDto?,rideStatus: null == rideStatus ? _self.rideStatus : rideStatus // ignore: cast_nullable_to_non_nullable
as RideStatus,lastModified: freezed == lastModified ? _self.lastModified : lastModified // ignore: cast_nullable_to_non_nullable
as DateTime?,passengers: null == passengers ? _self._passengers : passengers // ignore: cast_nullable_to_non_nullable
as List<DriverProfileDto>,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$DriverProfileDtoCopyWith<$Res>? get driver {
    if (_self.driver == null) {
    return null;
  }

  return $DriverProfileDtoCopyWith<$Res>(_self.driver!, (value) {
    return _then(_self.copyWith(driver: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityDtoCopyWith<$Res> get origin {
  
  return $CityDtoCopyWith<$Res>(_self.origin, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityDtoCopyWith<$Res> get destination {
  
  return $CityDtoCopyWith<$Res>(_self.destination, (value) {
    return _then(_self.copyWith(destination: value));
  });
}/// Create a copy of RideResponseDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VehicleResponseDtoCopyWith<$Res>? get vehicle {
    if (_self.vehicle == null) {
    return null;
  }

  return $VehicleResponseDtoCopyWith<$Res>(_self.vehicle!, (value) {
    return _then(_self.copyWith(vehicle: value));
  });
}
}

// dart format on
