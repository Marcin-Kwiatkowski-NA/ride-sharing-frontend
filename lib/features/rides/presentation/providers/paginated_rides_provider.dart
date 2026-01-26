import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/dto/search_criteria_dto.dart';
import '../../data/ride_repository.dart';
import '../../domain/ride_presentation.dart';
import '../../domain/ride_ui_model.dart';
import 'search_criteria_provider.dart';

/// State for paginated rides list.
class PaginatedRidesState {
  final List<RideUiModel> rides;
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
    List<RideUiModel>? rides,
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
class PaginatedRidesNotifier extends Notifier<PaginatedRidesState> {
  @override
  PaginatedRidesState build() {
    // Watch search criteria - reset when it changes
    final criteria = ref.watch(searchCriteriaProvider);

    // Trigger initial load
    Future.microtask(() => _loadInitial(criteria));

    return const PaginatedRidesState(isLoading: true);
  }

  Future<void> _loadInitial(SearchCriteriaDto criteria) async {
    state = const PaginatedRidesState(isLoading: true);

    try {
      final repository = ref.read(rideRepositoryProvider);
      final initialCriteria = criteria.copyWith(page: 0);
      final response = await repository.searchRides(initialCriteria);

      final rides = RidePresentation.toUiModels(response.content);

      state = PaginatedRidesState(
        rides: rides,
        isLoading: false,
        hasMore: !response.last,
        currentPage: 0,
      );
    } catch (e) {
      state = PaginatedRidesState(
        isLoading: false,
        hasMore: false,
        error: e,
      );
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

      final newRides = RidePresentation.toUiModels(response.content);

      state = state.copyWith(
        rides: [...state.rides, ...newRides],
        isLoading: false,
        hasMore: !response.last,
        currentPage: nextPage,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e,
      );
    }
  }

  /// Refresh the list from the beginning.
  Future<void> refresh() async {
    final criteria = ref.read(searchCriteriaProvider);
    await _loadInitial(criteria);
  }
}

/// Provider for paginated rides.
final paginatedRidesProvider =
    NotifierProvider<PaginatedRidesNotifier, PaginatedRidesState>(
  PaginatedRidesNotifier.new,
);
