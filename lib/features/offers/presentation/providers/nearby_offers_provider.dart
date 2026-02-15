import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/utils/geo_utils.dart' show defaultNearbyRadiusKm, haversineKm;
import '../../../rides/data/ride_repository.dart';
import '../../../rides/domain/ride_presentation.dart';
import '../../../rides/presentation/providers/search_criteria_provider.dart';
import '../../../rides/presentation/providers/search_mode_provider.dart';
import '../../../seats/data/seat_repository.dart';
import '../../../seats/domain/seat_presentation.dart';
import '../../domain/nearby_offer_entry.dart';

part 'nearby_offers_provider.g.dart';

/// Status of the nearby/proximity search.
enum NearbyStatus { idle, loading, loaded, error }

/// State for the nearby offers search.
class NearbyOffersState {
  final NearbyStatus status;
  final List<NearbyOfferEntry> offers;
  final Object? error;

  const NearbyOffersState({
    this.status = NearbyStatus.idle,
    this.offers = const [],
    this.error,
  });

  NearbyOffersState copyWith({
    NearbyStatus? status,
    List<NearbyOfferEntry>? offers,
    Object? error,
  }) {
    return NearbyOffersState(
      status: status ?? this.status,
      offers: offers ?? this.offers,
      error: error,
    );
  }
}

/// Notifier for proximity-based search results.
///
/// Auto-disposed — nearby results don't survive navigation.
/// Watches [searchCriteriaProvider] to reset when the user performs a new
/// exact search. The [searchNearby] method must be called explicitly
/// (button tap) with the set of exact offer keys for deduplication.
@riverpod
class NearbyOffers extends _$NearbyOffers {
  int _requestId = 0;

  @override
  NearbyOffersState build() {
    ref.watch(searchCriteriaProvider);
    return const NearbyOffersState();
  }

  /// Fire a proximity search.
  ///
  /// [exactOfferKeys] contains route-param keys (e.g. `"r-123"`, `"s-456"`)
  /// of offers already shown in the exact results list, used for deduplication.
  Future<void> searchNearby({
    required Set<String> exactOfferKeys,
    double radiusKm = defaultNearbyRadiusKm,
  }) async {
    final currentRequestId = ++_requestId;
    state = const NearbyOffersState(status: NearbyStatus.loading);

    final criteria = ref.read(searchCriteriaProvider);
    final mode = ref.read(searchModeProvider);
    final searchOrigin = criteria.origin!;
    final searchDest = criteria.destination!;

    try {
      final List<NearbyOfferEntry> entries;

      if (mode == SearchMode.rides) {
        final repo = ref.read(rideRepositoryProvider);
        final response =
            await repo.searchRidesNearby(criteria, radiusKm: radiusKm);

        if (_requestId != currentRequestId || !ref.mounted) return;

        entries = response.content
            .map((dto) {
              final originDist = _distanceOrNull(
                searchOrigin.latitude,
                searchOrigin.longitude,
                dto.origin.latitude,
                dto.origin.longitude,
              );
              final destDist = _distanceOrNull(
                searchDest.latitude,
                searchDest.longitude,
                dto.destination.latitude,
                dto.destination.longitude,
              );
              return NearbyOfferEntry(
                offer: RidePresentation.toUiModel(dto),
                originDistanceKm: originDist,
                destinationDistanceKm: destDist,
              );
            })
            .where(
              (e) =>
                  !exactOfferKeys.contains(e.offer.offerKey.toRouteParam()),
            )
            .toList();
      } else {
        final repo = ref.read(seatRepositoryProvider);
        final response =
            await repo.searchSeatsNearby(criteria, radiusKm: radiusKm);

        if (_requestId != currentRequestId || !ref.mounted) return;

        entries = response.content
            .map((dto) {
              final originDist = _distanceOrNull(
                searchOrigin.latitude,
                searchOrigin.longitude,
                dto.origin.latitude,
                dto.origin.longitude,
              );
              final destDist = _distanceOrNull(
                searchDest.latitude,
                searchDest.longitude,
                dto.destination.latitude,
                dto.destination.longitude,
              );
              return NearbyOfferEntry(
                offer: SeatPresentation.toUiModel(dto),
                originDistanceKm: originDist,
                destinationDistanceKm: destDist,
              );
            })
            .where(
              (e) =>
                  !exactOfferKeys.contains(e.offer.offerKey.toRouteParam()),
            )
            .toList();
      }

      state = NearbyOffersState(status: NearbyStatus.loaded, offers: entries);
    } catch (e) {
      if (_requestId != currentRequestId || !ref.mounted) return;
      state = NearbyOffersState(status: NearbyStatus.error, error: e);
    }
  }

  /// Returns haversine distance in km, or null if < 1 km (exact match)
  /// or if coordinates are missing.
  double? _distanceOrNull(
    double searchLat,
    double searchLon,
    double? resultLat,
    double? resultLon,
  ) {
    if (resultLat == null || resultLon == null) return null;
    final km = haversineKm(searchLat, searchLon, resultLat, resultLon);
    return km < 1 ? null : km;
  }
}
