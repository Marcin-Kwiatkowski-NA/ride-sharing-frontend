import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/contact_method_dto.dart';
import '../data/offer_enums.dart';
import 'offer_models.dart';
import 'offer_ui_model.dart';
import 'part_of_day.dart';

/// Pure formatting helpers shared by all offer kind mappers.
///
/// Stateless, no side effects, easily testable.
class OfferFormatting {
  static final _shortDateFormat = DateFormat('EEE, MMM d');
  static final _timeFormat = DateFormat('HH:mm');

  /// Format date for display.
  static String formatDate(DateTime date) => _shortDateFormat.format(date);

  /// Format exact time, returning null if approximate or undefined.
  static String? formatExactTime(DateTime time, bool isApproximate) {
    if (isTimeUndefined(time, isApproximate) || isApproximate) return null;
    return _timeFormat.format(time);
  }

  /// Format price per seat.
  static String formatPrice(double? pricePerSeat) {
    if (pricePerSeat == null) return 'Ask driver';
    return '${pricePerSeat.toStringAsFixed(0)} PLN';
  }

  /// Format price with a custom fallback label.
  static String formatPriceOrFallback(double? price, String fallback) {
    if (price == null) return fallback;
    return '${price.toStringAsFixed(0)} PLN';
  }

  /// Format capacity display (e.g. "3 seats", "1 seat").
  static String formatCapacity(int available, {String unit = 'seat'}) {
    return available == 1 ? '1 $unit' : '$available ${unit}s';
  }

  /// Build source badge (text, color) from RideSource.
  static ({String text, Color color}) formatSourceBadge(RideSource source) {
    final isInternal = source == RideSource.internal;
    return (
      text: isInternal ? 'Verified member' : 'Community listing',
      color: isInternal ? Colors.green.shade700 : Colors.orange.shade700,
    );
  }

  /// Build a StatusChipSpec from ride status.
  static StatusChipSpec buildRideStatusChip(String label, Color color, IconData icon) {
    return StatusChipSpec(label: label, color: color, icon: icon);
  }

  /// Build a ContactMethodUi from a DTO.
  static ContactMethodUi buildContactMethodUi(ContactMethodDto dto) {
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
          preview: truncateUrl(dto.value),
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
