import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/environment_config.dart';
import '../providers/auth_notifier.dart';
import 'auth_interceptor.dart';

part 'dio_provider.g.dart';

/// Riverpod provider for configured Dio instance.
///
/// Includes:
/// - Base URL from EnvironmentConfig
/// - Auth interceptor (reads token from memory)
/// - Token expiration handling (calls authProvider.handleTokenExpiration)
/// - Logging in development mode
@Riverpod(keepAlive: true)
Dio dio(Ref ref) {
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

  // Add auth interceptor with token expiration handling
  dio.interceptors.add(AuthInterceptor(
    ref,
    onTokenExpired: () {
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
