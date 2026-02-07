import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../offers/data/offer_search_criteria.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../data/ride_repository.dart';
import '../../domain/ride_presentation.dart';
import 'search_criteria_provider.dart';

part 'paginated_rides_provider.g.dart';

/// State for paginated rides list.
class PaginatedRidesState {
  final List<OfferUiModel> rides;
  final bool isLoading;
  final bool hasMore;
  final Object? error;
  final int currentPage;

  const PaginatedRidesState({
    this.rides = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  PaginatedRidesState copyWith({
    List<OfferUiModel>? rides,
    bool? isLoading,
    bool? hasMore,
    Object? error,
    int? currentPage,
  }) {
    return PaginatedRidesState(
      rides: rides ?? this.rides,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Notifier for paginated rides with infinite scroll support.
///
/// Uses keepAlive to preserve loaded rides across navigation.
@Riverpod(keepAlive: true)
class PaginatedRides extends _$PaginatedRides {
  @override
  PaginatedRidesState build() {
    final criteria = ref.watch(searchCriteriaProvider);
    _loadInitial(criteria);
    return const PaginatedRidesState(isLoading: true);
  }

  Future<void> _loadInitial(OfferSearchCriteria criteria) async {
    state = const PaginatedRidesState(isLoading: true);

    try {
      final repository = ref.read(rideRepositoryProvider);
      final initialCriteria = criteria.copyWith(page: 0);
      final response = await repository.searchRides(initialCriteria);

      if (!ref.mounted) return;

      final rides = RidePresentation.toUiModels(response.content);

      state = PaginatedRidesState(
        rides: rides,
        isLoading: false,
        hasMore: !response.last,
        currentPage: 0,
      );
    } catch (e) {
      if (!ref.mounted) return;
      state = PaginatedRidesState(isLoading: false, hasMore: false, error: e);
    }
  }

  /// Load the next page of rides.
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true);

    try {
      final criteria = ref.read(searchCriteriaProvider);
      final repository = ref.read(rideRepositoryProvider);

      final nextPage = state.currentPage + 1;
      final nextCriteria = criteria.copyWith(page: nextPage);
      final response = await repository.searchRides(nextCriteria);

      if (!ref.mounted) return;

      final newRides = RidePresentation.toUiModels(response.content);

      state = state.copyWith(
        rides: [...state.rides, ...newRides],
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
