import 'package:freezed_annotation/freezed_annotation.dart';

import 'user_profile.dart';

part 'auth_response.freezed.dart';
part 'auth_response.g.dart';

@freezed
sealed class AuthResponse with _$AuthResponse {
  const factory AuthResponse({
    required String accessToken,
    required String refreshToken,
    @Default('Bearer') String tokenType,
    required int expiresIn,
    required int refreshExpiresIn,
    required UserProfile user,
  }) = _AuthResponse;

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
}
