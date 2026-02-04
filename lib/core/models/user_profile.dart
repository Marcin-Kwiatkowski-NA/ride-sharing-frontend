import 'package:freezed_annotation/freezed_annotation.dart';

import 'account_status.dart';
import 'user_stats.dart';
import 'vehicle.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
sealed class UserProfile with _$UserProfile {
  const factory UserProfile({
    required int id,
    required String email,
    required AccountStatus status,
    required String displayName,
    String? phoneNumber,
    String? avatarUrl,
    String? bio,
    required UserStats stats,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    @Default([]) List<Vehicle> vehicles,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
