// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'driver_profile_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$DriverProfileDto {

 int get id; String? get username; String? get name; String? get email; String? get phoneNumber;
/// Create a copy of DriverProfileDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DriverProfileDtoCopyWith<DriverProfileDto> get copyWith => _$DriverProfileDtoCopyWithImpl<DriverProfileDto>(this as DriverProfileDto, _$identity);

  /// Serializes this DriverProfileDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DriverProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,email,phoneNumber);

@override
String toString() {
  return 'DriverProfileDto(id: $id, username: $username, name: $name, email: $email, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class $DriverProfileDtoCopyWith<$Res>  {
  factory $DriverProfileDtoCopyWith(DriverProfileDto value, $Res Function(DriverProfileDto) _then) = _$DriverProfileDtoCopyWithImpl;
@useResult
$Res call({
 int id, String? username, String? name, String? email, String? phoneNumber
});




}
/// @nodoc
class _$DriverProfileDtoCopyWithImpl<$Res>
    implements $DriverProfileDtoCopyWith<$Res> {
  _$DriverProfileDtoCopyWithImpl(this._self, this._then);

  final DriverProfileDto _self;
  final $Res Function(DriverProfileDto) _then;

/// Create a copy of DriverProfileDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = freezed,Object? name = freezed,Object? email = freezed,Object? phoneNumber = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [DriverProfileDto].
extension DriverProfileDtoPatterns on DriverProfileDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DriverProfileDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DriverProfileDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DriverProfileDto value)  $default,){
final _that = this;
switch (_that) {
case _DriverProfileDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DriverProfileDto value)?  $default,){
final _that = this;
switch (_that) {
case _DriverProfileDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int id,  String? username,  String? name,  String? email,  String? phoneNumber)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DriverProfileDto() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.email,_that.phoneNumber);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int id,  String? username,  String? name,  String? email,  String? phoneNumber)  $default,) {final _that = this;
switch (_that) {
case _DriverProfileDto():
return $default(_that.id,_that.username,_that.name,_that.email,_that.phoneNumber);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int id,  String? username,  String? name,  String? email,  String? phoneNumber)?  $default,) {final _that = this;
switch (_that) {
case _DriverProfileDto() when $default != null:
return $default(_that.id,_that.username,_that.name,_that.email,_that.phoneNumber);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DriverProfileDto implements DriverProfileDto {
  const _DriverProfileDto({required this.id, this.username, this.name, this.email, this.phoneNumber});
  factory _DriverProfileDto.fromJson(Map<String, dynamic> json) => _$DriverProfileDtoFromJson(json);

@override final  int id;
@override final  String? username;
@override final  String? name;
@override final  String? email;
@override final  String? phoneNumber;

/// Create a copy of DriverProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DriverProfileDtoCopyWith<_DriverProfileDto> get copyWith => __$DriverProfileDtoCopyWithImpl<_DriverProfileDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DriverProfileDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DriverProfileDto&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.name, name) || other.name == name)&&(identical(other.email, email) || other.email == email)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,name,email,phoneNumber);

@override
String toString() {
  return 'DriverProfileDto(id: $id, username: $username, name: $name, email: $email, phoneNumber: $phoneNumber)';
}


}

/// @nodoc
abstract mixin class _$DriverProfileDtoCopyWith<$Res> implements $DriverProfileDtoCopyWith<$Res> {
  factory _$DriverProfileDtoCopyWith(_DriverProfileDto value, $Res Function(_DriverProfileDto) _then) = __$DriverProfileDtoCopyWithImpl;
@override @useResult
$Res call({
 int id, String? username, String? name, String? email, String? phoneNumber
});




}
/// @nodoc
class __$DriverProfileDtoCopyWithImpl<$Res>
    implements _$DriverProfileDtoCopyWith<$Res> {
  __$DriverProfileDtoCopyWithImpl(this._self, this._then);

  final _DriverProfileDto _self;
  final $Res Function(_DriverProfileDto) _then;

/// Create a copy of DriverProfileDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = freezed,Object? name = freezed,Object? email = freezed,Object? phoneNumber = freezed,}) {
  return _then(_DriverProfileDto(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as int,username: freezed == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String?,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
