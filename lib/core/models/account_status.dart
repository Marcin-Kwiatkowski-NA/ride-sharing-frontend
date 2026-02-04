import 'package:json_annotation/json_annotation.dart';

/// Account status enum matching backend AccountStatus.
/// Decoding fails loudly on unknown values (no default).
enum AccountStatus {
  @JsonValue('ACTIVE')
  active,
  @JsonValue('BANNED')
  banned,
  @JsonValue('DISABLED')
  disabled;
}
