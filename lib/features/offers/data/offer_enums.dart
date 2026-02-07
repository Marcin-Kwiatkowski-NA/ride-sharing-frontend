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
enum ContactType {
  @JsonValue('PHONE')
  phone('PHONE'),
  @JsonValue('FACEBOOK_LINK')
  facebookLink('FACEBOOK_LINK'),
  @JsonValue('EMAIL')
  email('EMAIL');

  const ContactType(this.value);
  final String value;
}
