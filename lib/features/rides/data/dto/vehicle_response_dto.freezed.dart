// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vehicle_response_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VehicleResponseDto {

 int get id; String? get make; String? get model; int? get productionYear; String? get color; String? get licensePlate;
/// Create a copy of VehicleResponseDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VehicleResponseDtoCopyWith<VehicleResponseDto> get copyWith => _$VehicleResponseDtoCopyWithImpl<VehicleResponseDto>(this as VehicleResponseDto, _$identity);

  /// Serializes this VehicleResponseDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VehicleResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,make,model,productionYear,color,licensePlate);

@override
String toString() {
  return 'VehicleResponseDto(id: $id, make: $make, model: $model, productionYear: $productionYear, color: $color, licensePlate: $licensePlate)';
}


}

/// @nodoc
abstract mixin class $VehicleResponseDtoCopyWith<$Res>  {
  factory $VehicleResponseDtoCopyWith(VehicleResponseDto value, $Res Function(VehicleResponseDto) _then) = _$VehicleResponseDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? make, String? model, int? productionYear, String? color, String? licensePlate
});




}
/// @nodoc
class _$VehicleResponseDtoCopyWithImpl<$Res>
    implements $VehicleResponseDtoCopyWith<$Res> {
  _$VehicleResponseDtoCopyWithImpl(this._self, this._then);

  final VehicleResponseDto _self;
  final $Res Function(VehicleResponseDto) _then;

/// Create a copy of VehicleResponseDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? make = freezed,Object? model = freezed,Object? productionYear = freezed,Object? color = freezed,Object? licensePlate = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,licensePlate: freezed == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [VehicleResponseDto].
extension VehicleResponseDtoPatterns on VehicleResponseDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VehicleResponseDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VehicleResponseDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VehicleResponseDto value)  $default,){
final _that = this;
switch (_that) {
case _VehicleResponseDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VehicleResponseDto value)?  $default,){
final _that = this;
switch (_that) {
case _VehicleResponseDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? make,  String? model,  int? productionYear,  String? color,  String? licensePlate)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VehicleResponseDto() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.productionYear,_that.color,_that.licensePlate);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? make,  String? model,  int? productionYear,  String? color,  String? licensePlate)  $default,) {final _that = this;
switch (_that) {
case _VehicleResponseDto():
return $default(_that.id,_that.make,_that.model,_that.productionYear,_that.color,_that.licensePlate);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? make,  String? model,  int? productionYear,  String? color,  String? licensePlate)?  $default,) {final _that = this;
switch (_that) {
case _VehicleResponseDto() when $default != null:
return $default(_that.id,_that.make,_that.model,_that.productionYear,_that.color,_that.licensePlate);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VehicleResponseDto implements VehicleResponseDto {
  const _VehicleResponseDto({required this.id, this.make, this.model, this.productionYear, this.color, this.licensePlate});
  factory _VehicleResponseDto.fromJson(Map<String, dynamic> json) => _$VehicleResponseDtoFromJson(json);

@override final  int id;
@override final  String? make;
@override final  String? model;
@override final  int? productionYear;
@override final  String? color;
@override final  String? licensePlate;

/// Create a copy of VehicleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VehicleResponseDtoCopyWith<_VehicleResponseDto> get copyWith => __$VehicleResponseDtoCopyWithImpl<_VehicleResponseDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VehicleResponseDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VehicleResponseDto&&(identical(other.id, id) || other.id == id)&&(identical(other.make, make) || other.make == make)&&(identical(other.model, model) || other.model == model)&&(identical(other.productionYear, productionYear) || other.productionYear == productionYear)&&(identical(other.color, color) || other.color == color)&&(identical(other.licensePlate, licensePlate) || other.licensePlate == licensePlate));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,make,model,productionYear,color,licensePlate);

@override
String toString() {
  return 'VehicleResponseDto(id: $id, make: $make, model: $model, productionYear: $productionYear, color: $color, licensePlate: $licensePlate)';
}


}

/// @nodoc
abstract mixin class _$VehicleResponseDtoCopyWith<$Res> implements $VehicleResponseDtoCopyWith<$Res> {
  factory _$VehicleResponseDtoCopyWith(_VehicleResponseDto value, $Res Function(_VehicleResponseDto) _then) = __$VehicleResponseDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? make, String? model, int? productionYear, String? color, String? licensePlate
});




}
/// @nodoc
class __$VehicleResponseDtoCopyWithImpl<$Res>
    implements _$VehicleResponseDtoCopyWith<$Res> {
  __$VehicleResponseDtoCopyWithImpl(this._self, this._then);

  final _VehicleResponseDto _self;
  final $Res Function(_VehicleResponseDto) _then;

/// Create a copy of VehicleResponseDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? make = freezed,Object? model = freezed,Object? productionYear = freezed,Object? color = freezed,Object? licensePlate = freezed,}) {
  return _then(_VehicleResponseDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,make: freezed == make ? _self.make : make // ignore: cast_nullable_to_non_nullable
as String?,model: freezed == model ? _self.model : model // ignore: cast_nullable_to_non_nullable
as String?,productionYear: freezed == productionYear ? _self.productionYear : productionYear // ignore: cast_nullable_to_non_nullable
as int?,color: freezed == color ? _self.color : color // ignore: cast_nullable_to_non_nullable
as String?,licensePlate: freezed == licensePlate ? _self.licensePlate : licensePlate // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
