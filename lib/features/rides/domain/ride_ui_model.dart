import 'package:flutter/material.dart';

import '../data/dto/ride_enums.dart';

/// Precomputed UI model for ride display.
///
/// Contains all formatted strings and computed values needed by widgets.
/// This separation allows for:
/// 1. Pure business logic in the mapper (easily testable)
/// 2. No formatting logic in widgets
/// 3. Consistent display across the app
@immutable
class RideUiModel {
  final int id;

  // Route
  final String originName;
  final String destinationName;
  final String routeDisplay;

  // Time
  final String dateDisplay;
  final String timeDisplay;
  final String fullDateTimeDisplay;
  final bool isApproximate;

  // Seats & Price
  final int availableSeats;
  final String seatsDisplay;
  final String priceDisplay;
  final bool hasPrice;

  // Source
  final RideSource source;
  final String sourceBadgeText;
  final Color sourceBadgeColor;
  final bool isInternal;

  // Driver
  final String? driverName;
  final String? driverPhone;
  final bool hasDriverPhone;

  // External
  final String? externalUrl;
  final bool hasExternalUrl;

  // Status
  final RideStatus status;
  final String statusDisplay;
  final bool isBookable;

  // CTA
  final String ctaText;
  final bool ctaEnabled;

  const RideUiModel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.routeDisplay,
    required this.dateDisplay,
    required this.timeDisplay,
    required this.fullDateTimeDisplay,
    required this.isApproximate,
    required this.availableSeats,
    required this.seatsDisplay,
    required this.priceDisplay,
    required this.hasPrice,
    required this.source,
    required this.sourceBadgeText,
    required this.sourceBadgeColor,
    required this.isInternal,
    required this.driverName,
    required this.driverPhone,
    required this.hasDriverPhone,
    required this.externalUrl,
    required this.hasExternalUrl,
    required this.status,
    required this.statusDisplay,
    required this.isBookable,
    required this.ctaText,
    required this.ctaEnabled,
  });
}
