import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/dto/contact_method_dto.dart';
import '../data/dto/ride_enums.dart';
import '../data/dto/ride_response_dto.dart';
import 'part_of_day.dart';
import 'ride_ui_model.dart';

/// Pure function mapper: RideResponseDto -> RideUiModel.
///
/// Stateless, no side effects, easily testable.
/// All formatting logic is centralized here.
class RidePresentation {
  static final _shortDateFormat = DateFormat('EEE, MMM d');
  static final _timeFormat = DateFormat('HH:mm');

  /// Convert DTO to UI model with all precomputed display values.
  static RideUiModel toUiModel(RideResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Build contact methods list (ordered: PHONE, FACEBOOK_LINK, EMAIL)
    final contactMethods = <ContactMethodUi>[];
    for (final type in [
      ContactType.phone,
      ContactType.facebookLink,
      ContactType.email
    ]) {
      final contact = _findContactByType(dto.contactMethods, type);
      if (contact != null) {
        contactMethods.add(_buildContactMethodUi(contact));
      }
    }

    // Time formatting with part-of-day
    final timeUndefined = isTimeUndefined(dto.departureTime, dto.isApproximate);
    final partOfDay = getPartOfDay(dto.departureTime);
    final partOfDayDisplay =
        timeUndefined ? 'Ask driver' : partOfDayLabel(partOfDay);

    // Exact time display (null if approximate or undefined)
    final String? exactTimeDisplay;
    if (timeUndefined || dto.isApproximate) {
      exactTimeDisplay = null;
    } else {
      exactTimeDisplay = _timeFormat.format(dto.departureTime);
    }

    // Price formatting
    final hasPrice = dto.pricePerSeat != null;
    final priceDisplay =
        hasPrice ? '${dto.pricePerSeat!.toStringAsFixed(0)} PLN' : 'Ask driver';

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
      routeDisplay: '${dto.origin.name} -> ${dto.destination.name}',
      dateDisplay: _shortDateFormat.format(dto.departureTime),
      exactTimeDisplay: exactTimeDisplay,
      partOfDay: partOfDay,
      partOfDayDisplay: partOfDayDisplay,
      isTimeUndefined: timeUndefined,
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
      driverRating: driverRating,
      driverCompletedRides: driverCompletedRides,
      showRating: showRating,
      description: dto.description,
      status: dto.rideStatus,
      statusDisplay: statusDisplay,
      isBookable: isBookable,
      contactMethods: contactMethods,
      hasAnyContactMethod: contactMethods.isNotEmpty,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<RideUiModel> toUiModels(List<RideResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

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

  static ContactMethodUi _buildContactMethodUi(ContactMethodDto dto) {
    switch (dto.type) {
      case ContactType.phone:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          label: 'Call',
          preview: dto.value,
          icon: Icons.phone_outlined,
        );
      case ContactType.facebookLink:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          label: 'Open Facebook post',
          preview: _truncateUrl(dto.value),
          icon: Icons.open_in_new,
        );
      case ContactType.email:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          label: 'Send email',
          preview: dto.value,
          icon: Icons.email_outlined,
        );
    }
  }

  static String _truncateUrl(String url) {
    var display = url.replaceFirst(RegExp(r'^https?://'), '');
    display = display.replaceFirst(RegExp(r'^www\.'), '');
    if (display.length > 30) {
      display = '${display.substring(0, 27)}...';
    }
    return display;
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
