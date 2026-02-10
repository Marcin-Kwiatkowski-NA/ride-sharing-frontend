import 'package:flutter/material.dart';

import '../../offers/data/offer_enums.dart';
import '../../offers/domain/offer_formatting.dart';
import '../../offers/domain/offer_models.dart';
import '../../offers/domain/offer_ui_model.dart';
import '../../offers/domain/part_of_day.dart';
import '../../profile/public_profile/domain/public_profile_data.dart';
import '../data/dto/seat_enums.dart';
import '../data/dto/seat_response_dto.dart';

/// Pure function mapper: SeatResponseDto -> OfferUiModel.
///
/// Stateless, no side effects, easily testable.
class SeatPresentation {
  /// Convert DTO to unified offer UI model with raw data fields.
  static OfferUiModel toUiModel(SeatResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Contact methods (ordered: PHONE, FACEBOOK_LINK, EMAIL)
    final contactMethods =
        OfferFormatting.buildContactMethods(dto.contactMethods);

    // Time
    final timeUndefined =
        isTimeUndefined(dto.departureTime, dto.isApproximate);
    final partOfDay = getPartOfDay(dto.departureTime);
    final exactTimeDisplay = OfferFormatting.formatExactTime(
      dto.departureTime,
      dto.isApproximate,
    );

    // Status
    final status = _mapStatus(dto.seatStatus);
    final isBookable = dto.seatStatus == SeatStatus.searching;

    // Passenger / User info
    final passengerName = dto.passenger?.name;
    final passengerRating = dto.passenger?.rating;
    final passengerCompletedRides = dto.passenger?.completedRides;
    final showRating = passengerCompletedRides != null &&
        passengerCompletedRides > 0 &&
        passengerRating != null;
    final passengerId = dto.passenger?.id;
    final canUseInAppChat = isInternal && passengerId != null;

    final OfferUserUi? user = dto.passenger != null
        ? OfferUserUi(
            displayName: _hasContent(passengerName) ? passengerName! : '',
            rating: passengerRating,
            completedTrips: passengerCompletedRides,
            showRating: showRating,
            userId: passengerId,
            canUseInAppChat: canUseInAppChat,
            chatContext: ChatContext(OfferKind.seat, dto.id),
            contactMethods: contactMethods,
            profileData: dto.passenger?.toPublicProfileData(),
          )
        : null;

    return OfferUiModel(
      offerKey: OfferKey(OfferKind.seat, dto.id),
      originName: dto.origin.name,
      destinationName: dto.destination.name,
      routeDisplay: '${dto.origin.name} -> ${dto.destination.name}',
      departureTime: dto.departureTime,
      exactTimeDisplay: exactTimeDisplay,
      partOfDay: partOfDay,
      isTimeUndefined: timeUndefined,
      moneyLabelKind: MoneyLabelKind.budget,
      moneyAmount: dto.priceWillingToPay,
      countLabelKind: CountLabelKind.passengers,
      count: dto.count,
      countIcon: Icons.people,
      isExternalSource: !isInternal,
      status: status,
      isBookable: isBookable,
      user: user,
      description: dto.description,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<OfferUiModel> toUiModels(List<SeatResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

  static OfferStatus _mapStatus(SeatStatus status) => switch (status) {
    SeatStatus.searching => OfferStatus.searching,
    SeatStatus.booked => OfferStatus.booked,
    SeatStatus.expired => OfferStatus.expired,
    SeatStatus.cancelled => OfferStatus.cancelled,
    SeatStatus.banned => OfferStatus.banned,
  };

  static bool _hasContent(String? s) => s != null && s.trim().isNotEmpty;
}
