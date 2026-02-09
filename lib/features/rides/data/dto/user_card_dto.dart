import 'package:freezed_annotation/freezed_annotation.dart';

import 'vehicle_response_dto.dart';

part 'user_card_dto.freezed.dart';
part 'user_card_dto.g.dart';

@freezed
sealed class UserCardDto with _$UserCardDto {
  const factory UserCardDto({
    required int id,
    required String name,
    double? rating,
    int? completedRides,
    String? avatarUrl,
    String? bio,
    @Default(false) bool emailVerified,
    @Default(false) bool phoneVerified,
    @Default(0) int ridesGiven,
    @Default(0) int ridesTaken,
    @Default(0) int ratingCount,
    @Default([]) List<VehicleResponseDto> vehicles,
  }) = _UserCardDto;

  factory UserCardDto.fromJson(Map<String, dynamic> json) =>
      _$UserCardDtoFromJson(json);
}
