// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'search_criteria_dto.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SearchCriteriaDto {

 City? get origin; City? get destination; DateTime? get departureDate; DateTime? get departureDateTo; TimeOfDay? get departureTimeFrom; int get minAvailableSeats; int get page; int get size;
/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SearchCriteriaDtoCopyWith<SearchCriteriaDto> get copyWith => _$SearchCriteriaDtoCopyWithImpl<SearchCriteriaDto>(this as SearchCriteriaDto, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SearchCriteriaDto&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureDateTo, departureDateTo) || other.departureDateTo == departureDateTo)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.minAvailableSeats, minAvailableSeats) || other.minAvailableSeats == minAvailableSeats)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureDateTo,departureTimeFrom,minAvailableSeats,page,size);

@override
String toString() {
  return 'SearchCriteriaDto(origin: $origin, destination: $destination, departureDate: $departureDate, departureDateTo: $departureDateTo, departureTimeFrom: $departureTimeFrom, minAvailableSeats: $minAvailableSeats, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class $SearchCriteriaDtoCopyWith<$Res>  {
  factory $SearchCriteriaDtoCopyWith(SearchCriteriaDto value, $Res Function(SearchCriteriaDto) _then) = _$SearchCriteriaDtoCopyWithImpl;
@useResult
$Res call({
 City? origin, City? destination, DateTime? departureDate, DateTime? departureDateTo, TimeOfDay? departureTimeFrom, int minAvailableSeats, int page, int size
});


$CityCopyWith<$Res>? get origin;$CityCopyWith<$Res>? get destination;

}
/// @nodoc
class _$SearchCriteriaDtoCopyWithImpl<$Res>
    implements $SearchCriteriaDtoCopyWith<$Res> {
  _$SearchCriteriaDtoCopyWithImpl(this._self, this._then);

  final SearchCriteriaDto _self;
  final $Res Function(SearchCriteriaDto) _then;

/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureDateTo = freezed,Object? departureTimeFrom = freezed,Object? minAvailableSeats = null,Object? page = null,Object? size = null,}) {
  return _then(_self.copyWith(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as City?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as City?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureDateTo: freezed == departureDateTo ? _self.departureDateTo : departureDateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,minAvailableSeats: null == minAvailableSeats ? _self.minAvailableSeats : minAvailableSeats // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}
/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $CityCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $CityCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}


/// Adds pattern-matching-related methods to [SearchCriteriaDto].
extension SearchCriteriaDtoPatterns on SearchCriteriaDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SearchCriteriaDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SearchCriteriaDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SearchCriteriaDto value)  $default,){
final _that = this;
switch (_that) {
case _SearchCriteriaDto():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SearchCriteriaDto value)?  $default,){
final _that = this;
switch (_that) {
case _SearchCriteriaDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( City? origin,  City? destination,  DateTime? departureDate,  DateTime? departureDateTo,  TimeOfDay? departureTimeFrom,  int minAvailableSeats,  int page,  int size)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SearchCriteriaDto() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureDateTo,_that.departureTimeFrom,_that.minAvailableSeats,_that.page,_that.size);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( City? origin,  City? destination,  DateTime? departureDate,  DateTime? departureDateTo,  TimeOfDay? departureTimeFrom,  int minAvailableSeats,  int page,  int size)  $default,) {final _that = this;
switch (_that) {
case _SearchCriteriaDto():
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureDateTo,_that.departureTimeFrom,_that.minAvailableSeats,_that.page,_that.size);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( City? origin,  City? destination,  DateTime? departureDate,  DateTime? departureDateTo,  TimeOfDay? departureTimeFrom,  int minAvailableSeats,  int page,  int size)?  $default,) {final _that = this;
switch (_that) {
case _SearchCriteriaDto() when $default != null:
return $default(_that.origin,_that.destination,_that.departureDate,_that.departureDateTo,_that.departureTimeFrom,_that.minAvailableSeats,_that.page,_that.size);case _:
  return null;

}
}

}

/// @nodoc


class _SearchCriteriaDto implements SearchCriteriaDto {
  const _SearchCriteriaDto({this.origin, this.destination, this.departureDate, this.departureDateTo, this.departureTimeFrom, this.minAvailableSeats = 1, this.page = 0, this.size = 10});
  

@override final  City? origin;
@override final  City? destination;
@override final  DateTime? departureDate;
@override final  DateTime? departureDateTo;
@override final  TimeOfDay? departureTimeFrom;
@override@JsonKey() final  int minAvailableSeats;
@override@JsonKey() final  int page;
@override@JsonKey() final  int size;

/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SearchCriteriaDtoCopyWith<_SearchCriteriaDto> get copyWith => __$SearchCriteriaDtoCopyWithImpl<_SearchCriteriaDto>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SearchCriteriaDto&&(identical(other.origin, origin) || other.origin == origin)&&(identical(other.destination, destination) || other.destination == destination)&&(identical(other.departureDate, departureDate) || other.departureDate == departureDate)&&(identical(other.departureDateTo, departureDateTo) || other.departureDateTo == departureDateTo)&&(identical(other.departureTimeFrom, departureTimeFrom) || other.departureTimeFrom == departureTimeFrom)&&(identical(other.minAvailableSeats, minAvailableSeats) || other.minAvailableSeats == minAvailableSeats)&&(identical(other.page, page) || other.page == page)&&(identical(other.size, size) || other.size == size));
}


@override
int get hashCode => Object.hash(runtimeType,origin,destination,departureDate,departureDateTo,departureTimeFrom,minAvailableSeats,page,size);

@override
String toString() {
  return 'SearchCriteriaDto(origin: $origin, destination: $destination, departureDate: $departureDate, departureDateTo: $departureDateTo, departureTimeFrom: $departureTimeFrom, minAvailableSeats: $minAvailableSeats, page: $page, size: $size)';
}


}

/// @nodoc
abstract mixin class _$SearchCriteriaDtoCopyWith<$Res> implements $SearchCriteriaDtoCopyWith<$Res> {
  factory _$SearchCriteriaDtoCopyWith(_SearchCriteriaDto value, $Res Function(_SearchCriteriaDto) _then) = __$SearchCriteriaDtoCopyWithImpl;
@override @useResult
$Res call({
 City? origin, City? destination, DateTime? departureDate, DateTime? departureDateTo, TimeOfDay? departureTimeFrom, int minAvailableSeats, int page, int size
});


@override $CityCopyWith<$Res>? get origin;@override $CityCopyWith<$Res>? get destination;

}
/// @nodoc
class __$SearchCriteriaDtoCopyWithImpl<$Res>
    implements _$SearchCriteriaDtoCopyWith<$Res> {
  __$SearchCriteriaDtoCopyWithImpl(this._self, this._then);

  final _SearchCriteriaDto _self;
  final $Res Function(_SearchCriteriaDto) _then;

/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? origin = freezed,Object? destination = freezed,Object? departureDate = freezed,Object? departureDateTo = freezed,Object? departureTimeFrom = freezed,Object? minAvailableSeats = null,Object? page = null,Object? size = null,}) {
  return _then(_SearchCriteriaDto(
origin: freezed == origin ? _self.origin : origin // ignore: cast_nullable_to_non_nullable
as City?,destination: freezed == destination ? _self.destination : destination // ignore: cast_nullable_to_non_nullable
as City?,departureDate: freezed == departureDate ? _self.departureDate : departureDate // ignore: cast_nullable_to_non_nullable
as DateTime?,departureDateTo: freezed == departureDateTo ? _self.departureDateTo : departureDateTo // ignore: cast_nullable_to_non_nullable
as DateTime?,departureTimeFrom: freezed == departureTimeFrom ? _self.departureTimeFrom : departureTimeFrom // ignore: cast_nullable_to_non_nullable
as TimeOfDay?,minAvailableSeats: null == minAvailableSeats ? _self.minAvailableSeats : minAvailableSeats // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityCopyWith<$Res>? get origin {
    if (_self.origin == null) {
    return null;
  }

  return $CityCopyWith<$Res>(_self.origin!, (value) {
    return _then(_self.copyWith(origin: value));
  });
}/// Create a copy of SearchCriteriaDto
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CityCopyWith<$Res>? get destination {
    if (_self.destination == null) {
    return null;
  }

  return $CityCopyWith<$Res>(_self.destination!, (value) {
    return _then(_self.copyWith(destination: value));
  });
}
}

// dart format on
