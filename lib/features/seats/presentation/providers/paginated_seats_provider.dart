import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../offers/data/offer_search_criteria.dart';
import '../../../offers/presentation/paginated_offer_notifier.dart';
import '../../../rides/presentation/providers/search_criteria_provider.dart';
import '../../data/seat_repository.dart';
import '../../domain/seat_presentation.dart';

part 'paginated_seats_provider.g.dart';

/// Notifier for paginated seats with infinite scroll support.
///
/// Uses keepAlive to preserve loaded seats across navigation.
@Riverpod(keepAlive: true)
class PaginatedSeats extends _$PaginatedSeats {
  @override
  PaginatedOfferState build() {
    final criteria = ref.watch(searchCriteriaProvider);
    _loadInitial(criteria);
    return const PaginatedOfferState(isLoading: true);
  }

  Future<void> _loadInitial(OfferSearchCriteria criteria) async {
    state = const PaginatedOfferState(isLoading: true);

    try {
      final repository = ref.read(seatRepositoryProvider);
      final initialCriteria = criteria.copyWith(page: 0);
      final response = await repository.searchSeats(initialCriteria);

      if (!ref.mounted) return;

      final seats = SeatPresentation.toUiModels(response.content);

      state = PaginatedOfferState(
        offers: seats,
        isLoading: false,
        hasMore: !response.last,
        currentPage: 0,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = PaginatedOfferState(isLoading: false, hasMore: false, error: e);
    }
  }

  /// Load the next page of seats.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final criteria = ref.read(searchCriteriaProvider);
      final repository = ref.read(seatRepositoryProvider);

      final nextPage = state.currentPage + 1;
      final nextCriteria = criteria.copyWith(page: nextPage);
      final response = await repository.searchSeats(nextCriteria);

      if (!ref.mounted) return;

      final newSeats = SeatPresentation.toUiModels(response.content);

      state = state.copyWith(
        offers: [...state.offers, ...newSeats],
        isLoading: false,
        hasMore: !response.last,
        currentPage: nextPage,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  /// Refresh the list from the beginning.
  Future<void> refresh() async {
    final criteria = ref.read(searchCriteriaProvider);
    await _loadInitial(criteria);
  }
}
