import 'package:json_annotation/json_annotation.dart';

enum SeatStatus {
  @JsonValue('SEARCHING')
  searching,
  @JsonValue('BOOKED')
  booked,
  @JsonValue('EXPIRED')
  expired,
  @JsonValue('CANCELLED')
  cancelled,
  @JsonValue('BANNED')
  banned,
}
