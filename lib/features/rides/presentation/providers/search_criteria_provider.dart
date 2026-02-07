import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/cities/domain/city.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../offers/data/offer_search_criteria.dart';
import '../../data/dto/draft_search_criteria.dart';

part 'search_criteria_provider.g.dart';

/// Notifier for managing search criteria state.
///
/// Uses keepAlive to preserve search criteria across navigation.
@Riverpod(keepAlive: true)
class SearchCriteria extends _$SearchCriteria {
  @override
  OfferSearchCriteria build() {
    return const OfferSearchCriteria();
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
    state = const OfferSearchCriteria();
  }

  /// Swap origin and destination cities.
  void swapOriginDestination() {
    state = state.copyWith(
      origin: state.destination,
      destination: state.origin,
    );
  }

  /// Atomically commit a draft to the search criteria.
  void commitDraft(DraftSearchCriteria draft) {
    state = state.copyWith(
      origin: draft.origin,
      destination: draft.destination,
      departureDate:
          draft.departureDate != null ? normalizeDate(draft.departureDate!) : null,
      departureTimeFrom: draft.anyTime ? null : draft.departureTime,
      page: 0,
    );
  }
}
