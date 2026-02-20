import 'package:freezed_annotation/freezed_annotation.dart';

part 'booking_failure.freezed.dart';

/// Typed failure cases for booking operations.
///
/// Mapped from ProblemDetail responses in the repository layer.
/// UI resolves these to localized user-facing messages.
@freezed
sealed class BookingFailure with _$BookingFailure {
  /// Passenger already has an active booking on this ride.
  const factory BookingFailure.alreadyBooked() = AlreadyBooked;

  /// Not enough seats for the requested seatCount.
  const factory BookingFailure.insufficientSeats() = InsufficientSeats;

  /// Ride status is not OPEN (full, completed, cancelled, etc.).
  const factory BookingFailure.rideNotBookable() = RideNotBookable;

  /// Attempting to book a FACEBOOK (external) ride.
  const factory BookingFailure.externalRide() = ExternalRide;

  /// Board stop is after alight stop, or stop not found on the ride.
  const factory BookingFailure.invalidSegment() = InvalidSegment;

  /// Network or connection error.
  const factory BookingFailure.network(String message) = NetworkFailure;

  /// Unrecognized or unexpected error.
  const factory BookingFailure.unknown(String message) = UnknownFailure;
}
