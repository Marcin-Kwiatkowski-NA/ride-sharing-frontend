import '../../../../core/cities/domain/city.dart';

/// Data passed to PostSeatScreen to pre-fill form fields from search criteria.
class SeatPrefill {
  final City? origin;
  final City? destination;
  final DateTime? date;

  const SeatPrefill({this.origin, this.destination, this.date});
}
