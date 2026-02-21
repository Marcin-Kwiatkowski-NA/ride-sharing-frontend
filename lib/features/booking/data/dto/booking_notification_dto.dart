import 'package:freezed_annotation/freezed_annotation.dart';

import 'booking_enums.dart';

part 'booking_notification_dto.freezed.dart';
part 'booking_notification_dto.g.dart';

/// STOMP event DTO received on `/user/queue/bookings`.
///
/// Matches backend `BookingNotificationDto` record.
@freezed
sealed class BookingNotificationDto with _$BookingNotificationDto {
  const factory BookingNotificationDto({
    required int bookingId,
    required int rideId,
    required BookingStatus status,
    required String eventType,
    @Default(1) int seatCount,
    required String rideOrigin,
    required String rideDestination,
    DateTime? departureTime,
    String? counterpartyName,
  }) = _BookingNotificationDto;

  factory BookingNotificationDto.fromJson(Map<String, dynamic> json) =>
      _$BookingNotificationDtoFromJson(json);
}
