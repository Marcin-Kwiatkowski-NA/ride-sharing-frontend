import 'package:flutter/material.dart';

import '../data/dto/booking_enums.dart';

/// Presentation model for a booking in the My Activity → Bookings list.
///
/// Contains pre-resolved display strings (stop names, formatted time).
/// Immutable value object — no provider references.
@immutable
class BookingUiModel {
  final int bookingId;
  final int rideId;
  final BookingStatus status;
  final int seatCount;
  final String boardStopName;
  final String alightStopName;
  final DateTime departureTime;
  final DateTime bookedAt;
  final DateTime? resolvedAt;

  const BookingUiModel({
    required this.bookingId,
    required this.rideId,
    required this.status,
    required this.seatCount,
    required this.boardStopName,
    required this.alightStopName,
    required this.departureTime,
    required this.bookedAt,
    this.resolvedAt,
  });
}
