import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/locations/domain/location.dart';
import '../../../offers/data/location_dto.dart';
import '../../data/ride_repository.dart';

part 'ride_route_provider.g.dart';

/// Immutable route data extracted from a ride for smart-match consumption.
typedef RideRouteData = ({List<Location> stops, DateTime departureDate});

/// Provides the ordered stops and departure date for a ride.
///
/// Fetches the ride DTO and converts [LocationDto]s to core [Location]s.
/// Auto-disposes when the details screen is popped.
@riverpod
Future<RideRouteData> rideRoute(Ref ref, int rideId) async {
  final repository = ref.watch(rideRepositoryProvider);
  final dto = await repository.getRideById(rideId);

  final sortedStops = [...dto.stops]
    ..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));

  final intermediateLocations = sortedStops
      .where((s) => s.stopOrder > 0 && s.stopOrder < sortedStops.length - 1)
      .map((s) => s.location.toLocation());

  final stops = [
    dto.origin.toLocation(),
    ...intermediateLocations,
    dto.destination.toLocation(),
  ];

  return (stops: stops, departureDate: dto.departureTime);
}
