import 'package:json_annotation/json_annotation.dart';

@JsonEnum(valueField: 'value')
enum RideSource {
  @JsonValue('INTERNAL')
  internal('INTERNAL'),
  @JsonValue('FACEBOOK')
  facebook('FACEBOOK');

  const RideSource(this.value);
  final String value;
}

@JsonEnum(valueField: 'value')
enum RideStatus {
  @JsonValue('OPEN')
  open('OPEN'),
  @JsonValue('FULL')
  full('FULL'),
  @JsonValue('COMPLETED')
  completed('COMPLETED'),
  @JsonValue('CANCELLED')
  cancelled('CANCELLED');

  const RideStatus(this.value);
  final String value;
}
