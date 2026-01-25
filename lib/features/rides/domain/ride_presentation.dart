import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final hasPhone = dto.driver?.phoneNumber?.isNotEmpty == true;
    final hasExternal = dto.externalUrl?.isNotEmpty == true;

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

    // CTA (Call-to-Action)
    String ctaText;
    bool ctaEnabled;

    if (hasPhone) {
      ctaText = 'Call driver';
      ctaEnabled = true;
    } else if (hasExternal) {
      ctaText = 'View original post';
      ctaEnabled = true;
    } else if (isInternal) {
      ctaText = 'No phone available';
      ctaEnabled = false;
    } else {
      ctaText = 'Link unavailable';
      ctaEnabled = false;
    }

    // Driver name
    final driverName = dto.driver?.name ?? dto.driver?.username;

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
      seatsDisplay: seatsDisplay,
      priceDisplay: priceDisplay,
      hasPrice: hasPrice,
      source: dto.source,
      sourceBadgeText: sourceBadgeText,
      sourceBadgeColor: sourceBadgeColor,
      isInternal: isInternal,
      driverName: driverName,
      driverPhone: dto.driver?.phoneNumber,
      hasDriverPhone: hasPhone,
      externalUrl: dto.externalUrl,
      hasExternalUrl: hasExternal,
      status: dto.rideStatus,
      statusDisplay: statusDisplay,
      isBookable: isBookable,
      ctaText: ctaText,
      ctaEnabled: ctaEnabled,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<RideUiModel> toUiModels(List<RideResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
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
