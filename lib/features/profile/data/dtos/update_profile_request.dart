import 'package:freezed_annotation/freezed_annotation.dart';

part 'update_profile_request.freezed.dart';
part 'update_profile_request.g.dart';

@freezed
sealed class UpdateProfileRequest with _$UpdateProfileRequest {
  const factory UpdateProfileRequest({
    String? displayName,
    String? bio,
    String? phoneNumber,
  }) = _UpdateProfileRequest;

  factory UpdateProfileRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateProfileRequestFromJson(json);
}
