import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../../core/locations/domain/location.dart';
import '../../../../offers/data/offer_search_criteria.dart';
import '../../../../offers/domain/offer_ui_model.dart';
import '../../../../seats/data/dto/seat_response_dto.dart';
import '../../../../seats/data/seat_repository.dart';
import '../../../../seats/domain/seat_presentation.dart';

part 'smart_match_provider.g.dart';

const _radiusKm = 50.0;
const _maxSegments = 5;

/// Fetches seat requests matching a newly published ride's route and date.
///
/// [stops] is the ordered route: `[origin, ...intermediates, destination]`.
/// Uses proximity search (50 km radius) across route segments, with
/// full-route matches prioritised over partial-segment matches.
@riverpod
Future<List<OfferUiModel>> smartMatch(
  Ref ref, {
  required List<Location> stops,
  required DateTime departureDate,
}) async {
  assert(stops.length >= 2, 'Route must have at least origin and destination');

  final repository = ref.read(seatRepositoryProvider);
  final segments = _buildSegments(stops);

  // Fire all segment searches in parallel.
  final futures = segments.map((segment) {
    final (origin, destination) = segment;
    final criteria = OfferSearchCriteria(
      origin: origin,
      destination: destination,
      departureDate: departureDate,
    );
    return repository.searchSeatsNearby(criteria, radiusKm: _radiusKm);
  }).toList();

  final results = await Future.wait(futures);

  // Collect full-route match IDs for relevance sorting.
  final fullRouteIds = <int>{};
  if (results.isNotEmpty) {
    for (final seat in results.first.content) {
      fullRouteIds.add(seat.id);
    }
  }

  // Merge and deduplicate by seat id.
  final seenIds = <int>{};
  final uniqueSeats = <SeatResponseDto>[];
  for (final response in results) {
    for (final seat in response.content) {
      if (seenIds.add(seat.id)) {
        uniqueSeats.add(seat);
      }
    }
  }

  // Sort: full-route matches first, then by departure time proximity.
  uniqueSeats.sort((a, b) {
    final aFullRoute = fullRouteIds.contains(a.id);
    final bFullRoute = fullRouteIds.contains(b.id);
    if (aFullRoute != bFullRoute) return aFullRoute ? -1 : 1;

    final aDiff = a.departureTime.difference(departureDate).abs();
    final bDiff = b.departureTime.difference(departureDate).abs();
    return aDiff.compareTo(bDiff);
  });

  return SeatPresentation.toUiModels(uniqueSeats);
}

/// Generate search segment pairs from an ordered stops list.
///
/// Full route `(first, last)` is always first (highest priority).
/// Then consecutive pairs follow, up to [_maxSegments] total.
///
/// For `[O, D]`:           `[(O,D)]`                                     — 1
/// For `[O, S1, D]`:       `[(O,D), (O,S1), (S1,D)]`                    — 3
/// For `[O, S1, S2, D]`:   `[(O,D), (O,S1), (S1,S2), (S2,D)]`          — 4
/// For `[O, S1, S2, S3, D]`: `[(O,D), (O,S1), (S1,S2), (S2,S3), (S3,D)]` — 5
List<(Location, Location)> _buildSegments(List<Location> stops) {
  final segments = <(Location, Location)>[];

  // Always add full route first.
  segments.add((stops.first, stops.last));

  // Add consecutive pairs up to the cap.
  for (int i = 0; i < stops.length - 1 && segments.length < _maxSegments; i++) {
    // Skip if this consecutive pair is the same as the full route (no intermediates).
    if (stops.length == 2) break;
    segments.add((stops[i], stops[i + 1]));
  }

  return segments;
}
