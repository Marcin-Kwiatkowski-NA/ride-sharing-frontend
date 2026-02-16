import 'package:flutter/foundation.dart';

import '../../../offers/domain/offer_ui_model.dart';

/// Whether the passenger request matched the full ride route or a nearby segment.
enum SmartMatchType { fullRoute, nearbySegment }

/// Wrapper around [OfferUiModel] for smart-match results.
///
/// Carries computed distances from the ride's origin/destination to the
/// matched seat's origin/destination. Null distance means an exact match
/// (< 1 km). Raw doubles — UI layer formats display strings.
@immutable
class SmartMatchEntry {
  final OfferUiModel offer;
  final SmartMatchType matchType;
  final double? originDistanceKm;
  final double? destinationDistanceKm;

  const SmartMatchEntry({
    required this.offer,
    required this.matchType,
    this.originDistanceKm,
    this.destinationDistanceKm,
  });
}
