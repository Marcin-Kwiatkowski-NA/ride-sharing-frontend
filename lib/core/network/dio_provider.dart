import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/environment_config.dart';
import 'auth_interceptor.dart';

/// Riverpod provider for configured Dio instance.
///
/// Includes:
/// - Base URL from EnvironmentConfig
/// - Auth interceptor (reads token from memory)
/// - Logging in development mode
final dioProvider = Provider<Dio>((ref) {
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

  // Add auth interceptor
  dio.interceptors.add(AuthInterceptor(ref));

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
});
