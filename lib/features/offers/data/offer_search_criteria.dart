import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/cities/domain/city.dart';

part 'offer_search_criteria.freezed.dart';

@freezed
sealed class OfferSearchCriteria with _$OfferSearchCriteria {
  const factory OfferSearchCriteria({
    City? origin,
    City? destination,
    DateTime? departureDate,
    DateTime? departureDateTo,
    TimeOfDay? departureTimeFrom,
    @Default(1) int minAvailableSeats,
    int? availableSeatsInCar,
    @Default(0) int page,
    @Default(10) int size,
  }) = _OfferSearchCriteria;
}
