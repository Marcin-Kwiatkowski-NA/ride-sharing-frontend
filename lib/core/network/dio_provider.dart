import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/environment_config.dart';
import '../../services/auth_service.dart';
import '../providers/auth_notifier.dart';
import 'auth_interceptor.dart';

part 'dio_provider.g.dart';

/// Riverpod provider for configured Dio instance.
///
/// Includes:
/// - Base URL from EnvironmentConfig
/// - Auth interceptor with token refresh support
/// - Token expiration handling (calls authProvider.handleTokenExpiration)
/// - Logging in development mode
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
  final authService = AuthService();

  final dio = Dio(
    BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: EnvironmentConfig.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: EnvironmentConfig.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Add auth interceptor with token refresh and expiration handling
  dio.interceptors.add(AuthInterceptor(
    ref,
    refreshTokens: authService.refreshTokens,
    onAuthFailure: () {
      ref.read(authProvider.notifier).handleTokenExpiration();
    },
  ));

  // Add logging in development
  if (EnvironmentConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO] $obj'),
      ),
    );
  }

  return dio;
}
