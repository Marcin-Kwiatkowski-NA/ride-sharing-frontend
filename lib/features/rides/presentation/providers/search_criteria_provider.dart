import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dto/search_criteria_dto.dart';

/// Notifier for managing search criteria state.
class SearchCriteriaNotifier extends Notifier<SearchCriteriaDto> {
  @override
  SearchCriteriaDto build() {
    return const SearchCriteriaDto();
  }

  void setOrigin(String? origin) {
    state = state.copyWith(origin: origin);
  }

  void setDestination(String? destination) {
    state = state.copyWith(destination: destination);
  }

  void setDepartureDate(DateTime? date) {
    state = state.copyWith(departureDate: date);
  }

  void setDepartureTime(TimeOfDay? time) {
    state = state.copyWith(departureTimeFrom: time);
  }

  void setMinSeats(int seats) {
    state = state.copyWith(minSeats: seats);
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

/// Provider for search criteria state.
final searchCriteriaProvider =
    NotifierProvider<SearchCriteriaNotifier, SearchCriteriaDto>(
  SearchCriteriaNotifier.new,
);
