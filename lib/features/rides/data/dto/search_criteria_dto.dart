import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../core/cities/domain/city.dart';

part 'search_criteria_dto.freezed.dart';

@freezed
sealed class SearchCriteriaDto with _$SearchCriteriaDto {
  const factory SearchCriteriaDto({
    City? origin,
    City? destination,
    DateTime? departureDate,
    DateTime? departureDateTo,
    TimeOfDay? departureTimeFrom,
    @Default(1) int minAvailableSeats,
    @Default(0) int page,
    @Default(10) int size,
  }) = _SearchCriteriaDto;
}
