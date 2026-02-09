import 'package:flutter/material.dart';

import '../../offers/data/offer_enums.dart';
import '../../offers/domain/offer_formatting.dart';
import '../../offers/domain/offer_models.dart';
import '../../offers/domain/offer_ui_model.dart';
import '../../offers/domain/part_of_day.dart';
import '../data/dto/ride_enums.dart';
import '../data/dto/ride_response_dto.dart';

/// Pure function mapper: RideResponseDto -> OfferUiModel.
///
/// Stateless, no side effects, easily testable.
/// All formatting logic is centralized here.
class RidePresentation {
  /// Convert DTO to unified offer UI model with all precomputed display values.
  static OfferUiModel toUiModel(RideResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Contact methods (ordered: PHONE, FACEBOOK_LINK, EMAIL)
    final contactMethods = OfferFormatting.buildContactMethods(dto.contactMethods);

    // Time formatting
    final timeUndefined = isTimeUndefined(dto.departureTime, dto.isApproximate);
    final partOfDay = getPartOfDay(dto.departureTime);
    final partOfDayDisplay = timeUndefined
        ? 'Ask driver'
        : partOfDayLabel(partOfDay);
    final exactTimeDisplay = OfferFormatting.formatExactTime(
      dto.departureTime,
      dto.isApproximate,
    );

    // Money & Count
    final moneyHighlight = dto.pricePerSeat != null;
    final moneyValue = OfferFormatting.formatPrice(dto.pricePerSeat);
    final countDisplay = OfferFormatting.formatCapacity(dto.availableSeats);

    // Source badge
    final sourceBadge = OfferFormatting.formatSourceBadge(dto.source);

    // Status chip
    final statusChip = _buildStatusChip(dto.rideStatus);
    final isBookable =
        dto.rideStatus == RideStatus.open && dto.availableSeats > 0;

    // Driver / User info
    final driverName = dto.driver?.name;
    final driverRating = dto.driver?.rating;
    final driverCompletedRides = dto.driver?.completedRides;
    final showRating =
        driverCompletedRides != null &&
        driverCompletedRides > 0 &&
        driverRating != null;
    final driverId = dto.driver?.id;
    final driverDisplayName = _hasContent(driverName) ? driverName! : 'Driver';
    final canUseInAppChat = isInternal && driverId != null;

    final OfferUserUi? user = dto.driver != null
        ? OfferUserUi(
            sectionTitle: 'DRIVER',
            displayName: driverDisplayName,
            rating: driverRating,
            completedTrips: driverCompletedRides,
            showRating: showRating,
            userId: driverId,
            canUseInAppChat: canUseInAppChat,
            chatContext: ChatContext(OfferKind.ride, dto.id),
            contactMethods: contactMethods,
          )
        : null;

    return OfferUiModel(
      offerKey: OfferKey(OfferKind.ride, dto.id),
      originName: dto.origin.name,
      destinationName: dto.destination.name,
      routeDisplay: '${dto.origin.name} -> ${dto.destination.name}',
      dateDisplay: OfferFormatting.formatDate(dto.departureTime),
      exactTimeDisplay: exactTimeDisplay,
      partOfDay: partOfDay,
      partOfDayDisplay: partOfDayDisplay,
      isTimeUndefined: timeUndefined,
      moneyLabel: 'Price per seat',
      moneyValue: moneyValue,
      moneyHighlight: moneyHighlight,
      countLabel: 'Available seats',
      countDisplay: countDisplay,
      countIcon: Icons.airline_seat_recline_normal,
      sourceBadgeText: sourceBadge.text,
      sourceBadgeColor: sourceBadge.color,
      isExternalSource: !isInternal,
      statusChip: statusChip,
      isBookable: isBookable,
      user: user,
      description: dto.description,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<OfferUiModel> toUiModels(List<RideResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

  static StatusChipSpec _buildStatusChip(RideStatus status) {
    final (label, color, icon) = switch (status) {
      RideStatus.open => ('Open', Colors.green, Icons.check_circle_outline),
      RideStatus.full => ('Full', Colors.orange, Icons.block),
      RideStatus.completed => ('Completed', Colors.blue, Icons.done_all),
      RideStatus.cancelled => ('Cancelled', Colors.red, Icons.cancel_outlined),
    };
    return StatusChipSpec(label: label, color: color, icon: icon);
  }

  static bool _hasContent(String? s) => s != null && s.trim().isNotEmpty;
}
