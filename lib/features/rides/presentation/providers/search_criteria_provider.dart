import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cities/domain/city.dart';
import '../../data/dto/search_criteria_dto.dart';

part 'search_criteria_provider.g.dart';

/// Notifier for managing search criteria state.
///
/// Uses keepAlive to preserve search criteria across navigation.
@Riverpod(keepAlive: true)
class SearchCriteria extends _$SearchCriteria {
  @override
  SearchCriteriaDto build() {
    return const SearchCriteriaDto();
  }

  void setOrigin(City? city) {
    state = state.copyWith(origin: city);
  }

  void setDestination(City? city) {
    state = state.copyWith(destination: city);
  }

  void setDepartureDate(DateTime? date) {
    state = state.copyWith(departureDate: date);
  }

  void setDepartureDateTo(DateTime? date) {
    state = state.copyWith(departureDateTo: date);
  }

  void setDepartureTime(TimeOfDay? time) {
    state = state.copyWith(departureTimeFrom: time);
  }

  void setMinSeats(int seats) {
    state = state.copyWith(minAvailableSeats: seats);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void resetPage() {
    state = state.copyWith(page: 0);
  }

  void clear() {
    state = const SearchCriteriaDto();
  }
}
