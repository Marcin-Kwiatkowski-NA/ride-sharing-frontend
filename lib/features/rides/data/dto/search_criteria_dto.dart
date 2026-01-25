import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'search_criteria_dto.freezed.dart';

@freezed
sealed class SearchCriteriaDto with _$SearchCriteriaDto {
  const factory SearchCriteriaDto({
    String? origin,
    String? destination,
    DateTime? departureDate,
    TimeOfDay? departureTimeFrom,
    @Default(1) int minSeats,
    @Default(0) int page,
    @Default(10) int size,
  }) = _SearchCriteriaDto;
}
