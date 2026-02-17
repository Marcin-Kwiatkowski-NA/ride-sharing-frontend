import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum RideStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('FULL')
  full('FULL'),
  @JsonValue('COMPLETED')
  completed('COMPLETED'),
  @JsonValue('EXPIRED')
  expired('EXPIRED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED'),
  @JsonValue('BANNED')
  banned('BANNED');

  const RideStatus(this.value);
  final String value;
}
