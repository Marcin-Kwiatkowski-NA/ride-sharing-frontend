import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/contact_method_dto.dart';
import '../data/offer_enums.dart';
import 'offer_models.dart';
import 'part_of_day.dart';

/// Pure formatting helpers shared by all offer kind mappers.
///
/// Stateless, no side effects, easily testable.
/// String-producing methods have been moved to ARB localization;
/// this class retains only non-string logic.
class OfferFormatting {
  static final _timeFormat = DateFormat('HH:mm');

  /// Format exact time, returning null if approximate or undefined.
  static String? formatExactTime(DateTime time, bool isApproximate) {
    if (isTimeUndefined(time, isApproximate) || isApproximate) return null;
    return _timeFormat.format(time);
  }

  /// Build a ContactMethodUi from a DTO.
  ///
  /// Labels are no longer pre-computed; widgets resolve localized labels
  /// from [ContactType] via `context.l10n`.
  static ContactMethodUi buildContactMethodUi(ContactMethodDto dto) {
    switch (dto.type) {
      case ContactType.phone:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          preview: dto.value,
          icon: Icons.phone_outlined,
        );
      case ContactType.facebookLink:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          preview: truncateUrl(dto.value),
          icon: Icons.open_in_new,
        );
      case ContactType.email:
        return ContactMethodUi(
          type: dto.type,
          value: dto.value,
          preview: dto.value,
          icon: Icons.email_outlined,
        );
    }
  }

  /// Build ordered contact methods list from DTOs.
  static List<ContactMethodUi> buildContactMethods(
    List<ContactMethodDto> dtos,
  ) {
    final result = <ContactMethodUi>[];
    for (final type in [
      ContactType.phone,
      ContactType.facebookLink,
      ContactType.email,
    ]) {
      for (final dto in dtos) {
        if (dto.type == type) {
          result.add(buildContactMethodUi(dto));
          break;
        }
      }
    }
    return result;
  }

  /// Truncate URL for display preview.
  static String truncateUrl(String url) {
    var display = url.replaceFirst(RegExp(r'^https?://'), '');
    display = display.replaceFirst(RegExp(r'^www\.'), '');
    if (display.length > 30) {
      display = '${display.substring(0, 27)}...';
    }
    return display;
  }
}
