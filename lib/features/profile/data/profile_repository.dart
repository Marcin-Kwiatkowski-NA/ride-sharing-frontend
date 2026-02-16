import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blablafront/core/network/dio_provider.dart' show apiDioProvider;
import 'package:blablafront/core/models/user_profile.dart';
import 'dtos/update_profile_request.dart';

part 'profile_repository.g.dart';

abstract class IProfileRepository {
  Future<UserProfile> updateProfile(UpdateProfileRequest request);
  Future<void> deleteAccount();
}

class ProfileRepository implements IProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  @override
  Future<UserProfile> updateProfile(UpdateProfileRequest request) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      '/me',
      data: request.toJson(),
    );
    return UserProfile.fromJson(response.data!);
  }

  @override
  Future<void> deleteAccount() async {
    await _dio.delete<void>('/me');
  }
}

@Riverpod(keepAlive: true)
IProfileRepository profileRepository(Ref ref) {
  final dio = ref.watch(apiDioProvider);
  return ProfileRepository(dio);
}
