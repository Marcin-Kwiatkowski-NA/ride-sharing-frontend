import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../rides/data/dto/user_card_dto.dart';
import '../../../rides/data/dto/vehicle_response_dto.dart';

part 'public_profile_data.freezed.dart';

@freezed
sealed class PublicProfileData with _$PublicProfileData {
  const factory PublicProfileData({
    required int userId,
    required String displayName,
    String? avatarUrl,
    String? bio,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    @Default(0) int ridesGiven,
    @Default(0) int ridesTaken,
    double? ratingAvg,
    @Default(0) int ratingCount,
    @Default([]) List<VehicleResponseDto> vehicles,
  }) = _PublicProfileData;
}

extension UserCardDtoX on UserCardDto {
  PublicProfileData toPublicProfileData() => PublicProfileData(
        userId: id,
        displayName: name,
        avatarUrl: avatarUrl,
        bio: bio,
        isEmailVerified: emailVerified,
        isPhoneVerified: phoneVerified,
        ridesGiven: ridesGiven,
        ridesTaken: ridesTaken,
        ratingAvg: rating,
        ratingCount: ratingCount,
        vehicles: vehicles,
      );
}
