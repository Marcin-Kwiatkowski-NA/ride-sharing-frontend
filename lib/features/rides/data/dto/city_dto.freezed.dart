// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CityDto {

 int get placeId; String get name; String? get countryCode; int? get population;
/// Create a copy of CityDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityDtoCopyWith<CityDto> get copyWith => _$CityDtoCopyWithImpl<CityDto>(this as CityDto, _$identity);

  /// Serializes this CityDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CityDto&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.population, population) || other.population == population));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,countryCode,population);

@override
String toString() {
  return 'CityDto(placeId: $placeId, name: $name, countryCode: $countryCode, population: $population)';
}


}

/// @nodoc
abstract mixin class $CityDtoCopyWith<$Res>  {
  factory $CityDtoCopyWith(CityDto value, $Res Function(CityDto) _then) = _$CityDtoCopyWithImpl;
@useResult
$Res call({
 int placeId, String name, String? countryCode, int? population
});




}
/// @nodoc
class _$CityDtoCopyWithImpl<$Res>
    implements $CityDtoCopyWith<$Res> {
  _$CityDtoCopyWithImpl(this._self, this._then);

  final CityDto _self;
  final $Res Function(CityDto) _then;

/// Create a copy of CityDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? placeId = null,Object? name = null,Object? countryCode = freezed,Object? population = freezed,}) {
  return _then(_self.copyWith(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,population: freezed == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}

}


/// Adds pattern-matching-related methods to [CityDto].
extension CityDtoPatterns on CityDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CityDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CityDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CityDto value)  $default,){
final _that = this;
switch (_that) {
case _CityDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CityDto value)?  $default,){
final _that = this;
switch (_that) {
case _CityDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int placeId,  String name,  String? countryCode,  int? population)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CityDto() when $default != null:
return $default(_that.placeId,_that.name,_that.countryCode,_that.population);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int placeId,  String name,  String? countryCode,  int? population)  $default,) {final _that = this;
switch (_that) {
case _CityDto():
return $default(_that.placeId,_that.name,_that.countryCode,_that.population);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int placeId,  String name,  String? countryCode,  int? population)?  $default,) {final _that = this;
switch (_that) {
case _CityDto() when $default != null:
return $default(_that.placeId,_that.name,_that.countryCode,_that.population);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CityDto implements CityDto {
  const _CityDto({required this.placeId, required this.name, this.countryCode, this.population});
  factory _CityDto.fromJson(Map<String, dynamic> json) => _$CityDtoFromJson(json);

@override final  int placeId;
@override final  String name;
@override final  String? countryCode;
@override final  int? population;

/// Create a copy of CityDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityDtoCopyWith<_CityDto> get copyWith => __$CityDtoCopyWithImpl<_CityDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CityDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CityDto&&(identical(other.placeId, placeId) || other.placeId == placeId)&&(identical(other.name, name) || other.name == name)&&(identical(other.countryCode, countryCode) || other.countryCode == countryCode)&&(identical(other.population, population) || other.population == population));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,placeId,name,countryCode,population);

@override
String toString() {
  return 'CityDto(placeId: $placeId, name: $name, countryCode: $countryCode, population: $population)';
}


}

/// @nodoc
abstract mixin class _$CityDtoCopyWith<$Res> implements $CityDtoCopyWith<$Res> {
  factory _$CityDtoCopyWith(_CityDto value, $Res Function(_CityDto) _then) = __$CityDtoCopyWithImpl;
@override @useResult
$Res call({
 int placeId, String name, String? countryCode, int? population
});




}
/// @nodoc
class __$CityDtoCopyWithImpl<$Res>
    implements _$CityDtoCopyWith<$Res> {
  __$CityDtoCopyWithImpl(this._self, this._then);

  final _CityDto _self;
  final $Res Function(_CityDto) _then;

/// Create a copy of CityDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? placeId = null,Object? name = null,Object? countryCode = freezed,Object? population = freezed,}) {
  return _then(_CityDto(
placeId: null == placeId ? _self.placeId : placeId // ignore: cast_nullable_to_non_nullable
as int,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,countryCode: freezed == countryCode ? _self.countryCode : countryCode // ignore: cast_nullable_to_non_nullable
as String?,population: freezed == population ? _self.population : population // ignore: cast_nullable_to_non_nullable
as int?,
  ));
}


}

// dart format on
