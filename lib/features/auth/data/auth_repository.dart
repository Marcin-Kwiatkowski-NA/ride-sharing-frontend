import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:blablafront/core/network/dio_provider.dart';
import 'package:blablafront/core/models/auth_response.dart';
import 'package:blablafront/core/models/user_profile.dart';
import 'dtos/login_request.dart';
import 'dtos/register_request.dart';
import 'dtos/refresh_token_request.dart';

part 'auth_repository.g.dart';

/// Abstract interface for testing
abstract class IAuthRepository {
  Future<AuthResponse> login(LoginRequest request);
  Future<AuthResponse> register(RegisterRequest request);
  Future<AuthResponse> refresh(RefreshTokenRequest request);
  Future<UserProfile> me();
}

class AuthRepository implements IAuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/login',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/register',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  @override
  Future<AuthResponse> refresh(RefreshTokenRequest request) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: request.toJson(),
    );
    return AuthResponse.fromJson(response.data!);
  }

  @override
  Future<UserProfile> me() async {
    final response = await _dio.get<Map<String, dynamic>>('/auth/me');
    return UserProfile.fromJson(response.data!);
  }
}

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
}
