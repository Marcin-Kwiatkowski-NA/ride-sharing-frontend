import 'package:flutter/material.dart';

import '../../booking/domain/booking_mode.dart';
import '../../rides/data/dto/ride_stop_dto.dart';
import 'offer_models.dart';
import 'part_of_day.dart';

/// Kind of mobility offer.
enum OfferKind { ride, seat }

/// Kind-specific label for the money field.
enum MoneyLabelKind { pricePerSeat, budget }

/// Kind-specific label for the count field.
enum CountLabelKind { availableSeats, passengers }

/// Unified offer status across ride and seat kinds.
enum OfferStatus {
  // Ride statuses
  open,
  full,
  completed,
  // Seat statuses
  searching,
  booked,
  expired,
  // Shared
  cancelled,
  banned,
}

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

/// Intermediate stop for display in offer cards and details.
@immutable
class IntermediateStopUi {
  final String cityName;
  final String? timeDisplay; // formatted HH:mm or null
  final bool isNextDay; // true when stop crosses midnight → show "+1" badge

  const IntermediateStopUi({
    required this.cityName,
    this.timeDisplay,
    this.isNextDay = false,
  });
}

/// Unified UI model for any mobility offer (ride or seat).
///
/// Contains raw data fields. Widgets are responsible for formatting
/// display strings using [AppLocalizations] (context.l10n).
@immutable
class OfferUiModel {
  final OfferKey offerKey;

  // Route
  final String originName;
  final String destinationName;
  final String routeDisplay;

  // Time — raw data; widgets localize via ARB DateTime placeholders
  final DateTime departureTime;
  final String? exactTimeDisplay;
  final PartOfDay partOfDay;
  final bool isTimeUndefined;

  // Money (price/budget) — raw data; widgets format via l10n
  final MoneyLabelKind moneyLabelKind;
  final double? moneyAmount;

  // Count (seats/passengers) — raw data; widgets format via l10n
  final CountLabelKind countLabelKind;
  final int count;
  final IconData countIcon;

  // Source
  final bool isExternalSource;

  // Status — enum; widgets map to localized label + color + icon
  final OfferStatus? status;
  final bool isBookable;

  // User (nullable — some offers may be anonymous)
  final OfferUserUi? user;

  // Intermediate stops
  final List<IntermediateStopUi> intermediateStops;

  // Description
  final String? description;

  // Booking
  final BookingMode bookingMode;
  final List<RideStopDto> stops;

  // Search context (optional — for contextual stop highlighting)
  final int? searchOriginOsmId;
  final int? searchDestinationOsmId;

  const OfferUiModel({
    required this.offerKey,
    required this.originName,
    required this.destinationName,
    required this.routeDisplay,
    required this.departureTime,
    required this.exactTimeDisplay,
    required this.partOfDay,
    required this.isTimeUndefined,
    required this.moneyLabelKind,
    required this.moneyAmount,
    required this.countLabelKind,
    required this.count,
    required this.countIcon,
    required this.isExternalSource,
    required this.status,
    required this.isBookable,
    required this.user,
    required this.description,
    this.intermediateStops = const [],
    this.bookingMode = BookingMode.instant,
    this.stops = const [],
    this.searchOriginOsmId,
    this.searchDestinationOsmId,
  });

  /// Whether the offer has a concrete price/budget set.
  bool get hasMoneyAmount => moneyAmount != null;
}

/// Derive a topicKey for messaging from an OfferKey.
///
/// Convention: `offer:r-123` for rides, `offer:s-456` for seats.
/// Extensible for future types (e.g. `package:42`).
String topicKeyForOffer(OfferKey key) => 'offer:${key.toRouteParam()}';
