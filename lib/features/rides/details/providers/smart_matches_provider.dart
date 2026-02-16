import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/locations/domain/location.dart';
import '../../../../core/utils/geo_utils.dart';
import '../../../offers/data/offer_search_criteria.dart';
import '../../../seats/data/dto/seat_response_dto.dart';
import '../../../seats/data/seat_repository.dart';
import '../../../seats/domain/seat_presentation.dart';
import '../domain/smart_match_entry.dart';
import 'ride_route_provider.dart';

part 'smart_matches_provider.g.dart';

const _radiusKm = 50.0;
const _maxSegments = 5;

/// Fetches seat requests matching a published ride's route and date.
///
/// Keyed by [rideId] for stable caching and trivial invalidation.
/// Internally reads [rideRouteProvider] for route data.
@riverpod
Future<List<SmartMatchEntry>> smartMatches(Ref ref, int rideId) async {
  final routeData = await ref.watch(rideRouteProvider(rideId).future);
  final stops = routeData.stops;
  final departureDate = routeData.departureDate;

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
    final aFull = fullRouteIds.contains(a.id);
    final bFull = fullRouteIds.contains(b.id);
    if (aFull != bFull) return aFull ? -1 : 1;

    final aDiff = a.departureTime.difference(departureDate).abs();
    final bDiff = b.departureTime.difference(departureDate).abs();
    return aDiff.compareTo(bDiff);
  });

  // Build SmartMatchEntry list with match type and distances.
  final rideOrigin = stops.first;
  final rideDestination = stops.last;

  return uniqueSeats.map((seat) {
    final isFullRoute = fullRouteIds.contains(seat.id);

    return SmartMatchEntry(
      offer: SeatPresentation.toUiModel(seat),
      matchType:
          isFullRoute ? SmartMatchType.fullRoute : SmartMatchType.nearbySegment,
      originDistanceKm: _distanceOrNull(
        rideOrigin.latitude,
        rideOrigin.longitude,
        seat.origin.latitude,
        seat.origin.longitude,
      ),
      destinationDistanceKm: _distanceOrNull(
        rideDestination.latitude,
        rideDestination.longitude,
        seat.destination.latitude,
        seat.destination.longitude,
      ),
    );
  }).toList();
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

/// Generate search segment pairs from an ordered stops list.
///
/// Full route `(first, last)` is always first (highest priority).
/// Then consecutive pairs follow, up to [_maxSegments] total.
List<(Location, Location)> _buildSegments(List<Location> stops) {
  final segments = <(Location, Location)>[];

  // Always add full route first.
  segments.add((stops.first, stops.last));

  // Add consecutive pairs up to the cap.
  for (int i = 0;
      i < stops.length - 1 && segments.length < _maxSegments;
      i++) {
    // Skip if this consecutive pair is the same as the full route (no intermediates).
    if (stops.length == 2) break;
    segments.add((stops[i], stops[i + 1]));
  }

  return segments;
}
