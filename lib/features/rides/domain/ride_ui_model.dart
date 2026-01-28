import 'package:flutter/material.dart';

import '../data/dto/ride_enums.dart';
import 'part_of_day.dart';

/// UI representation of a contact method for display in bottom sheet.
@immutable
class ContactMethodUi {
  final ContactType type;
  final String value;
  final String label;
  final String preview;
  final IconData icon;

  const ContactMethodUi({
    required this.type,
    required this.value,
    required this.label,
    required this.preview,
    required this.icon,
  });
}

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
  final String? exactTimeDisplay;
  final PartOfDay partOfDay;
  final String partOfDayDisplay;
  final bool isTimeUndefined;

  // Seats & Price
  final int availableSeats;
  final int seatsTaken;
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
  final double? driverRating;
  final int? driverCompletedRides;
  final bool showRating;

  // Description
  final String? description;

  // Status
  final RideStatus status;
  final String statusDisplay;
  final bool isBookable;

  // Contact methods
  final List<ContactMethodUi> contactMethods;
  final bool hasAnyContactMethod;

  const RideUiModel({
    required this.id,
    required this.originName,
    required this.destinationName,
    required this.routeDisplay,
    required this.dateDisplay,
    required this.exactTimeDisplay,
    required this.partOfDay,
    required this.partOfDayDisplay,
    required this.isTimeUndefined,
    required this.availableSeats,
    required this.seatsTaken,
    required this.seatsDisplay,
    required this.priceDisplay,
    required this.hasPrice,
    required this.source,
    required this.sourceBadgeText,
    required this.sourceBadgeColor,
    required this.isInternal,
    required this.driverName,
    required this.driverRating,
    required this.driverCompletedRides,
    required this.showRating,
    required this.description,
    required this.status,
    required this.statusDisplay,
    required this.isBookable,
    required this.contactMethods,
    required this.hasAnyContactMethod,
  });
}
