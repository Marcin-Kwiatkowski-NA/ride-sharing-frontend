import 'package:flutter/material.dart';

import '../../../../l10n/generated/app_localizations.dart';
import '../../data/offer_enums.dart';
import '../../domain/offer_ui_model.dart';
import '../../domain/part_of_day.dart';

/// Centralized localization helpers for [OfferUiModel] fields.
///
/// Keeps the mapping from enums/raw data to localized strings in one place
/// instead of scattered across widgets.
extension OfferUiModelL10n on OfferUiModel {
  /// Localized departure date string.
  String localizedDate(AppLocalizations l10n) => l10n.offerDate(departureTime);

  /// Localized part-of-day label, or "Ask driver"/"Ask passenger" if undefined.
  String localizedPartOfDay(AppLocalizations l10n) {
    if (this.isTimeUndefined) {
      return offerKey.kind == OfferKind.ride ? l10n.askDriver : l10n.askPassenger;
    }
    return _partOfDayLabel(partOfDay, l10n);
  }

  /// Localized time display: exact time, part of day, or "Any time"/"Flexible".
  String localizedTimeDisplay(AppLocalizations l10n) {
    return exactTimeDisplay ?? localizedPartOfDay(l10n);
  }

  /// Localized money value string (e.g., "30 PLN", "Ask driver", "Flexible").
  String localizedMoneyValue(AppLocalizations l10n) {
    if (moneyAmount != null) {
      return l10n.formattedPrice(moneyAmount!.toInt());
    }
    return offerKey.kind == OfferKind.ride ? l10n.askAboutPrice : l10n.flexible;
  }

  /// Localized money field label.
  String localizedMoneyLabel(AppLocalizations l10n) => switch (moneyLabelKind) {
    MoneyLabelKind.pricePerSeat => l10n.pricePerSeat,
    MoneyLabelKind.budget => l10n.budget,
  };

  /// Localized count display (e.g., "3 seats", "1 passenger").
  String localizedCountDisplay(AppLocalizations l10n) =>
      switch (countLabelKind) {
        CountLabelKind.availableSeats => l10n.seatCount(count),
        CountLabelKind.passengers => l10n.passengerCount(count),
      };

  /// Localized count field label.
  String localizedCountLabel(AppLocalizations l10n) =>
      switch (countLabelKind) {
        CountLabelKind.availableSeats => l10n.availableSeats,
        CountLabelKind.passengers => l10n.passengers,
      };

  /// Localized source badge text.
  String localizedSourceBadge(AppLocalizations l10n) =>
      isExternalSource ? l10n.communityListing : l10n.verifiedMember;

  /// Source badge color (not locale-dependent, but co-located for convenience).
  Color sourceBadgeColor() =>
      isExternalSource ? Colors.orange.shade700 : Colors.green.shade700;
}

/// Localized status chip display.
extension OfferStatusL10n on OfferStatus {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    OfferStatus.open => l10n.statusOpen,
    OfferStatus.full => l10n.statusFull,
    OfferStatus.completed => l10n.statusCompleted,
    OfferStatus.cancelled => l10n.statusCancelled,
    OfferStatus.searching => l10n.statusSearching,
    OfferStatus.booked => l10n.statusBooked,
    OfferStatus.expired => l10n.statusExpired,
    OfferStatus.banned => l10n.statusBanned,
  };

  Color get color => switch (this) {
    OfferStatus.open => Colors.green,
    OfferStatus.full => Colors.orange,
    OfferStatus.completed => Colors.blue,
    OfferStatus.cancelled => Colors.red,
    OfferStatus.searching => Colors.green,
    OfferStatus.booked => Colors.blue,
    OfferStatus.expired => Colors.grey,
    OfferStatus.banned => Colors.red,
  };

  IconData get icon => switch (this) {
    OfferStatus.open => Icons.check_circle_outline,
    OfferStatus.full => Icons.block,
    OfferStatus.completed => Icons.done_all,
    OfferStatus.cancelled => Icons.cancel_outlined,
    OfferStatus.searching => Icons.search,
    OfferStatus.booked => Icons.check_circle_outline,
    OfferStatus.expired => Icons.timer_off_outlined,
    OfferStatus.banned => Icons.block,
  };
}

/// Localized contact method label.
extension ContactTypeL10n on ContactType {
  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ContactType.phone => l10n.callLabel,
    ContactType.facebookLink => l10n.openFacebookPost,
    ContactType.email => l10n.sendEmail,
  };
}

/// Localized user section title (DRIVER / PASSENGER).
extension OfferKindL10n on OfferKind {
  String localizedUserSectionTitle(AppLocalizations l10n) => switch (this) {
    OfferKind.ride => l10n.driverLabel,
    OfferKind.seat => l10n.passengerLabel,
  };

  String localizedFallbackName(AppLocalizations l10n) => switch (this) {
    OfferKind.ride => l10n.driverFallbackName,
    OfferKind.seat => l10n.passengerFallbackName,
  };
}

String _partOfDayLabel(PartOfDay pod, AppLocalizations l10n) =>
    switch (pod) {
      PartOfDay.morning => l10n.partOfDayMorning,
      PartOfDay.afternoon => l10n.partOfDayAfternoon,
      PartOfDay.evening => l10n.partOfDayEvening,
      PartOfDay.night => l10n.partOfDayNight,
    };
