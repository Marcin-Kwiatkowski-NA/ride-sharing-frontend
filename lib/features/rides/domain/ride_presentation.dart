import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../offers/data/offer_enums.dart';
import '../../offers/domain/offer_formatting.dart';
import '../../offers/domain/offer_models.dart';
import '../../offers/domain/offer_ui_model.dart';
import '../../offers/domain/part_of_day.dart';
import '../../profile/public_profile/domain/public_profile_data.dart';
import '../data/dto/ride_enums.dart';
import '../data/dto/ride_response_dto.dart';

/// Pure function mapper: RideResponseDto -> OfferUiModel.
///
/// Stateless, no side effects, easily testable.
/// All display strings are resolved by widgets via AppLocalizations.
class RidePresentation {
  /// Convert DTO to unified offer UI model with raw data fields.
  static OfferUiModel toUiModel(RideResponseDto dto) {
    final isInternal = dto.source == RideSource.internal;

    // Contact methods (ordered: PHONE, FACEBOOK_LINK, EMAIL)
    final contactMethods = OfferFormatting.buildContactMethods(dto.contactMethods);

    // Time
    final timeUndefined = isTimeUndefined(dto.departureTime, dto.isApproximate);
    final partOfDay = getPartOfDay(dto.departureTime);
    final exactTimeDisplay = OfferFormatting.formatExactTime(
      dto.departureTime,
      dto.isApproximate,
    );

    // Status
    final status = _mapStatus(dto.rideStatus);
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
    final canUseInAppChat = isInternal && driverId != null;

    final OfferUserUi? user = dto.driver != null
        ? OfferUserUi(
            displayName: _hasContent(driverName) ? driverName! : '',
            rating: driverRating,
            completedTrips: driverCompletedRides,
            showRating: showRating,
            userId: driverId,
            canUseInAppChat: canUseInAppChat,
            chatContext: ChatContext(OfferKind.ride, dto.id),
            contactMethods: contactMethods,
            profileData: dto.driver?.toPublicProfileData(),
          )
        : null;

    // Intermediate stops
    final intermediateStops = _buildIntermediateStops(dto);
    final routeDisplay = _buildRouteDisplay(dto, intermediateStops);

    return OfferUiModel(
      offerKey: OfferKey(OfferKind.ride, dto.id),
      originName: dto.origin.name,
      destinationName: dto.destination.name,
      routeDisplay: routeDisplay,
      departureTime: dto.departureTime,
      exactTimeDisplay: exactTimeDisplay,
      partOfDay: partOfDay,
      isTimeUndefined: timeUndefined,
      moneyLabelKind: MoneyLabelKind.pricePerSeat,
      moneyAmount: dto.pricePerSeat,
      countLabelKind: CountLabelKind.availableSeats,
      count: dto.availableSeats,
      countIcon: Icons.airline_seat_recline_normal,
      isExternalSource: !isInternal,
      status: status,
      isBookable: isBookable,
      user: user,
      description: dto.description,
      intermediateStops: intermediateStops,
    );
  }

  /// Convert list of DTOs to UI models.
  static List<OfferUiModel> toUiModels(List<RideResponseDto> dtos) {
    return dtos.map(toUiModel).toList();
  }

  static OfferStatus _mapStatus(RideStatus status) => switch (status) {
    RideStatus.open => OfferStatus.open,
    RideStatus.full => OfferStatus.full,
    RideStatus.completed => OfferStatus.completed,
    RideStatus.cancelled => OfferStatus.cancelled,
  };

  static bool _hasContent(String? s) => s != null && s.trim().isNotEmpty;

  static final _timeFormat = DateFormat('HH:mm');

  static List<IntermediateStopUi> _buildIntermediateStops(RideResponseDto dto) {
    if (dto.stops.length <= 2) return const [];

    final sorted = [...dto.stops]..sort((a, b) => a.stopOrder.compareTo(b.stopOrder));
    final originDay = sorted.first.departureTime?.day ?? dto.departureTime.day;

    return sorted
        .where((s) => s.stopOrder > 0 && s.stopOrder < sorted.length - 1)
        .map((s) => IntermediateStopUi(
              cityName: s.city.name,
              timeDisplay: s.departureTime != null
                  ? _timeFormat.format(s.departureTime!)
                  : null,
              isNextDay: s.departureTime != null &&
                  s.departureTime!.day != originDay,
            ))
        .toList();
  }

  static String _buildRouteDisplay(
    RideResponseDto dto,
    List<IntermediateStopUi> intermediateStops,
  ) {
    final parts = [
      dto.origin.name,
      ...intermediateStops.map((s) => s.cityName),
      dto.destination.name,
    ];
    return parts.join(' → ');
  }
}
