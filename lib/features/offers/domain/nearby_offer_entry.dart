import 'package:flutter/foundation.dart';

import 'offer_ui_model.dart';

/// Wrapper around [OfferUiModel] for nearby/proximity search results.
///
/// Carries computed distances from the user's searched origin/destination
/// to the offer's actual origin/destination. Null distance means the
/// location is an exact match (< 1 km).
@immutable
class NearbyOfferEntry {
  final OfferUiModel offer;
  final double? originDistanceKm;
  final double? destinationDistanceKm;

  const NearbyOfferEntry({
    required this.offer,
    this.originDistanceKm,
    this.destinationDistanceKm,
  });
}
