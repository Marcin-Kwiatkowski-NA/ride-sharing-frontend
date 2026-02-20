/// Booking mode derived from the ride's `autoApprove` flag.
///
/// UI code uses this enum instead of a raw boolean, so semantics
/// are clear everywhere: cards, detail screen, booking sheet.
enum BookingMode {
  /// Passengers are confirmed immediately upon booking.
  instant,

  /// Driver must manually confirm each booking request.
  request;

  bool get isInstant => this == instant;
  bool get isRequest => this == request;
}

/// Convert the backend `autoApprove` boolean to a [BookingMode].
BookingMode bookingModeFrom(bool autoApprove) =>
    autoApprove ? BookingMode.instant : BookingMode.request;
