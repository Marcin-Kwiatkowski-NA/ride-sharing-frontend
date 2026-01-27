import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/dto/contact_method_dto.dart';
import '../data/dto/ride_enums.dart';
import '../data/dto/ride_response_dto.dart';
import 'ride_ui_model.dart';

/// Pure function mapper: RideResponseDto -> RideUiModel.
///
/// Stateless, no side effects, easily testable.
/// All formatting logic is centralized here.
class RidePresentation {
  // Date formatters
  static final _shortDateFormat = DateFormat('EEE, MMM d');
  static final _fullDateFormat = DateFormat('EEEE, MMMM d, yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  /// Convert DTO to UI model with all precomputed display values.
  static RideUiModel toUiModel(RideResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Extract contact methods
    final phoneContact = _findContactByType(dto.contactMethods, ContactType.phone);
    final facebookContact = _findContactByType(dto.contactMethods, ContactType.facebookLink);

    final hasPhone = phoneContact != null;
    final hasExternal = facebookContact != null;

    // Time formatting with approximate indicator
    final timeStr = _timeFormat.format(dto.departureTime);
    final timeDisplay = dto.isApproximate ? '~$timeStr' : timeStr;

    // Full date-time for details screen
    final fullDateTime =
        '${_fullDateFormat.format(dto.departureTime)} at $timeDisplay';

    // Price formatting
    final hasPrice = dto.pricePerSeat != null;
    final priceDisplay =
        hasPrice ? '${dto.pricePerSeat!.toStringAsFixed(2)} PLN' : 'Ask driver';

    // Seats formatting
    final seatsDisplay =
        dto.availableSeats == 1 ? '1 seat' : '${dto.availableSeats} seats';

    // Source badge
    final sourceBadgeText =
        isInternal ? 'Verified member' : 'Community listing';
    final sourceBadgeColor =
        isInternal ? Colors.green.shade700 : Colors.orange.shade700;

    // Status
    final statusDisplay = _formatStatus(dto.rideStatus);
    final isBookable =
        dto.rideStatus == RideStatus.open && dto.availableSeats > 0;

    // CTA (Call-to-Action) - phone takes priority over link
    CtaType ctaType;
    String ctaText;
    bool ctaEnabled;

    if (hasPhone) {
      ctaType = CtaType.phone;
      ctaText = 'Call driver';
      ctaEnabled = true;
    } else if (hasExternal) {
      ctaType = CtaType.link;
      ctaText = 'View original post';
      ctaEnabled = true;
    } else if (isInternal) {
      ctaType = CtaType.disabled;
      ctaText = 'No phone available';
      ctaEnabled = false;
    } else {
      ctaType = CtaType.disabled;
      ctaText = 'Link unavailable';
      ctaEnabled = false;
    }

    // Driver info
    final driverName = dto.driver?.name;
    final driverRating = dto.driver?.rating;
    final driverCompletedRides = dto.driver?.completedRides;

    // Show rating only if completedRides > 0 and rating is available
    final showRating = driverCompletedRides != null &&
        driverCompletedRides > 0 &&
        driverRating != null;

    return RideUiModel(
      id: dto.id,
      originName: dto.origin.name,
      destinationName: dto.destination.name,
      routeDisplay: '${dto.origin.name} → ${dto.destination.name}',
      dateDisplay: _shortDateFormat.format(dto.departureTime),
      timeDisplay: timeDisplay,
      fullDateTimeDisplay: fullDateTime,
      isApproximate: dto.isApproximate,
      availableSeats: dto.availableSeats,
      seatsTaken: dto.seatsTaken,
      seatsDisplay: seatsDisplay,
      priceDisplay: priceDisplay,
      hasPrice: hasPrice,
      source: dto.source,
      sourceBadgeText: sourceBadgeText,
      sourceBadgeColor: sourceBadgeColor,
      isInternal: isInternal,
      driverName: driverName,
      driverPhone: phoneContact?.value,
      hasDriverPhone: hasPhone,
      driverRating: driverRating,
      driverCompletedRides: driverCompletedRides,
      showRating: showRating,
      sourceUrl: facebookContact?.value,
      hasExternalUrl: hasExternal,
      description: dto.description,
      status: dto.rideStatus,
      statusDisplay: statusDisplay,
      isBookable: isBookable,
      ctaType: ctaType,
      ctaText: ctaText,
      ctaEnabled: ctaEnabled,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<RideUiModel> toUiModels(List<RideResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

  /// Find contact method by type, returns null if not found.
  static ContactMethodDto? _findContactByType(
    List<ContactMethodDto> contacts,
    ContactType type,
  ) {
    for (final contact in contacts) {
      if (contact.type == type) {
        return contact;
      }
    }
    return null;
  }

  static String _formatStatus(RideStatus status) {
    switch (status) {
      case RideStatus.open:
        return 'Open';
      case RideStatus.full:
        return 'Full';
      case RideStatus.completed:
        return 'Completed';
      case RideStatus.cancelled:
        return 'Cancelled';
    }
  }
}
