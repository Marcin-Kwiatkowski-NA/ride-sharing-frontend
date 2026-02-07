import 'package:flutter/material.dart';

import 'offer_models.dart';
import 'part_of_day.dart';

/// Kind of mobility offer.
enum OfferKind { ride, seat }

/// Composite key identifying a specific offer.
///
/// Route-safe encoding: `r-123` for rides, `s-123` for seats.
/// Implements == / hashCode so it works as a provider family parameter.
@immutable
class OfferKey {
  final OfferKind kind;
  final int id;

  const OfferKey(this.kind, this.id);

  String toRouteParam() => '${kind == OfferKind.ride ? 'r' : 's'}-$id';

  static OfferKey? fromRouteParam(String param) {
    final parts = param.split('-');
    if (parts.length != 2) return null;

    final OfferKind kind;
    switch (parts[0]) {
      case 'r':
        kind = OfferKind.ride;
      case 's':
        kind = OfferKind.seat;
      default:
        return null;
    }

    final id = int.tryParse(parts[1]);
    if (id == null) return null;

    return OfferKey(kind, id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OfferKey && kind == other.kind && id == other.id;

  @override
  int get hashCode => Object.hash(kind, id);

  @override
  String toString() => 'OfferKey($kind, $id)';
}

/// Pre-computed status chip display spec.
@immutable
class StatusChipSpec {
  final String label;
  final Color color;
  final IconData icon;

  const StatusChipSpec({
    required this.label,
    required this.color,
    required this.icon,
  });
}

/// Unified UI model for any mobility offer (ride or seat).
///
/// Contains only pre-computed, UI-ready fields. Widgets should never
/// branch on [OfferKind] — all kind-specific logic is resolved during mapping.
@immutable
class OfferUiModel {
  final OfferKey offerKey;

  // Route
  final String originName;
  final String destinationName;
  final String routeDisplay;

  // Time
  final String dateDisplay;
  final String? exactTimeDisplay;
  final PartOfDay partOfDay;
  final String partOfDayDisplay;
  final bool isTimeUndefined;

  // Money (price/budget)
  final String moneyLabel;
  final String moneyValue;
  final bool moneyHighlight;

  // Count (seats/passengers)
  final String countLabel;
  final String countDisplay;
  final IconData countIcon;

  // Source
  final String sourceBadgeText;
  final Color sourceBadgeColor;

  // Status
  final StatusChipSpec? statusChip;
  final bool isBookable;

  // User (nullable — some offers may be anonymous)
  final OfferUserUi? user;

  // Description
  final String? description;

  const OfferUiModel({
    required this.offerKey,
    required this.originName,
    required this.destinationName,
    required this.routeDisplay,
    required this.dateDisplay,
    required this.exactTimeDisplay,
    required this.partOfDay,
    required this.partOfDayDisplay,
    required this.isTimeUndefined,
    required this.moneyLabel,
    required this.moneyValue,
    required this.moneyHighlight,
    required this.countLabel,
    required this.countDisplay,
    required this.countIcon,
    required this.sourceBadgeText,
    required this.sourceBadgeColor,
    required this.statusChip,
    required this.isBookable,
    required this.user,
    required this.description,
  });
}

/// Derive a topicKey for messaging from an OfferKey.
///
/// Convention: `offer:r-123` for rides, `offer:s-456` for seats.
/// Extensible for future types (e.g. `package:42`).
String topicKeyForOffer(OfferKey key) => 'offer:${key.toRouteParam()}';
