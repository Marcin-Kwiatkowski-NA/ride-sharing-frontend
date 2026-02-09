import 'package:flutter/material.dart';

import '../../offers/data/offer_enums.dart';
import '../../offers/domain/offer_formatting.dart';
import '../../offers/domain/offer_models.dart';
import '../../offers/domain/offer_ui_model.dart';
import '../../offers/domain/part_of_day.dart';
import '../data/dto/seat_enums.dart';
import '../data/dto/seat_response_dto.dart';

/// Pure function mapper: SeatResponseDto -> OfferUiModel.
///
/// Stateless, no side effects, easily testable.
class SeatPresentation {
  /// Convert DTO to unified offer UI model with all precomputed display values.
  static OfferUiModel toUiModel(SeatResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Contact methods (ordered: PHONE, FACEBOOK_LINK, EMAIL)
    final contactMethods =
        OfferFormatting.buildContactMethods(dto.contactMethods);

    // Time formatting
    final timeUndefined =
        isTimeUndefined(dto.departureTime, dto.isApproximate);
    final partOfDay = getPartOfDay(dto.departureTime);
    final partOfDayDisplay =
        timeUndefined ? 'Ask passenger' : partOfDayLabel(partOfDay);
    final exactTimeDisplay = OfferFormatting.formatExactTime(
      dto.departureTime,
      dto.isApproximate,
    );

    // Money (budget)
    final moneyHighlight = dto.priceWillingToPay != null;
    final moneyValue = OfferFormatting.formatPriceOrFallback(
      dto.priceWillingToPay,
      'Flexible',
    );

    // Count (passengers)
    final countDisplay =
        dto.count == 1 ? '1 passenger' : '${dto.count} passengers';

    // Source badge
    final sourceBadge = OfferFormatting.formatSourceBadge(dto.source);

    // Status chip
    final statusChip = _buildStatusChip(dto.seatStatus);
    final isBookable = dto.seatStatus == SeatStatus.searching;

    // Passenger / User info
    final passengerName = dto.passenger?.name;
    final passengerRating = dto.passenger?.rating;
    final passengerCompletedRides = dto.passenger?.completedRides;
    final showRating = passengerCompletedRides != null &&
        passengerCompletedRides > 0 &&
        passengerRating != null;
    final passengerId = dto.passenger?.id;
    final passengerDisplayName =
        _hasContent(passengerName) ? passengerName! : 'Passenger';
    final canUseInAppChat = isInternal && passengerId != null;

    final OfferUserUi? user = dto.passenger != null
        ? OfferUserUi(
            sectionTitle: 'PASSENGER',
            displayName: passengerDisplayName,
            rating: passengerRating,
            completedTrips: passengerCompletedRides,
            showRating: showRating,
            userId: passengerId,
            canUseInAppChat: canUseInAppChat,
            chatContext: ChatContext(OfferKind.seat, dto.id),
            contactMethods: contactMethods,
          )
        : null;

    return OfferUiModel(
      offerKey: OfferKey(OfferKind.seat, dto.id),
      originName: dto.origin.name,
      destinationName: dto.destination.name,
      routeDisplay: '${dto.origin.name} -> ${dto.destination.name}',
      dateDisplay: OfferFormatting.formatDate(dto.departureTime),
      exactTimeDisplay: exactTimeDisplay,
      partOfDay: partOfDay,
      partOfDayDisplay: partOfDayDisplay,
      isTimeUndefined: timeUndefined,
      moneyLabel: 'Budget',
      moneyValue: moneyValue,
      moneyHighlight: moneyHighlight,
      countLabel: 'Passengers',
      countDisplay: countDisplay,
      countIcon: Icons.people,
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
  static List<OfferUiModel> toUiModels(List<SeatResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

  static StatusChipSpec _buildStatusChip(SeatStatus status) {
    final (label, color, icon) = switch (status) {
      SeatStatus.searching => ('Searching', Colors.green, Icons.search),
      SeatStatus.booked => ('Booked', Colors.blue, Icons.check_circle_outline),
      SeatStatus.expired => ('Expired', Colors.grey, Icons.timer_off_outlined),
      SeatStatus.cancelled =>
        ('Cancelled', Colors.red, Icons.cancel_outlined),
      SeatStatus.banned => ('Banned', Colors.red, Icons.block),
    };
    return StatusChipSpec(label: label, color: color, icon: icon);
  }

  static bool _hasContent(String? s) => s != null && s.trim().isNotEmpty;
}
