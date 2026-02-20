import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum BookingStatus {
  @JsonValue('PENDING')
  pending('PENDING'),
  @JsonValue('CONFIRMED')
  confirmed('CONFIRMED'),
  @JsonValue('REJECTED')
  rejected('REJECTED'),
  @JsonValue('CANCELLED_BY_PASSENGER')
  cancelledByPassenger('CANCELLED_BY_PASSENGER'),
  @JsonValue('CANCELLED_BY_DRIVER')
  cancelledByDriver('CANCELLED_BY_DRIVER'),
  @JsonValue('EXPIRED')
  expired('EXPIRED');

  const BookingStatus(this.value);
  final String value;

  /// Whether this booking counts toward seat occupancy.
  bool get isActive => this == pending || this == confirmed;

  /// Whether this is a terminal state (no further transitions).
  bool get isTerminal => switch (this) {
    pending || confirmed => false,
    rejected || cancelledByPassenger || cancelledByDriver || expired => true,
  };

  /// Whether the passenger can cancel this booking.
  bool get isCancellable => this == pending || this == confirmed;
}
