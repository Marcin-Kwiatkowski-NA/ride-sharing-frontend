import '../../../../core/locations/domain/location.dart';

/// Data passed to PostSeatScreen to pre-fill form fields from search criteria.
class SeatPrefill {
  final Location? origin;
  final Location? destination;
  final DateTime? date;

  const SeatPrefill({this.origin, this.destination, this.date});
}
