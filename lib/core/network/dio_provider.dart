import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../config/environment_config.dart';
import '../../services/auth_service.dart';
import 'auth_interceptor.dart';
import 'auth_token_provider.dart';

part 'dio_provider.g.dart';

/// Shared base options for all Dio instances.
BaseOptions _baseOptions() => BaseOptions(
      baseUrl: EnvironmentConfig.apiBaseUrl,
      connectTimeout: Duration(seconds: EnvironmentConfig.apiTimeoutSeconds),
      receiveTimeout: Duration(seconds: EnvironmentConfig.apiTimeoutSeconds),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

/// Plain Dio instance with no auth interceptor.
///
/// Used by [authRepositoryProvider] for unauthenticated endpoints
/// (login, register, refresh) and auth bootstrap (me with manual token).
@Riverpod(keepAlive: true)
Dio rawDio(Ref ref) {
  final dio = Dio(_baseOptions());

  if (EnvironmentConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[DIO-RAW] $obj'),
      ),
    );
  }

  return dio;
}

/// Dio instance with auth interceptor for authenticated API calls.
///
/// Adds token to requests, handles 401 with token refresh, and clears
/// the token store on unrecoverable auth failures.
/// NEVER reads authProvider — depends only on Layer 1 (token store + auth service).
@Riverpod(keepAlive: true)
Dio apiDio(Ref ref) {
  final authService = ref.read(authServiceProvider);

  final dio = Dio(_baseOptions());

  dio.interceptors.add(AuthInterceptor(
    ref,
    refreshTokens: authService.refreshTokens,
    onAuthFailure: () {
      ref.read(authTokenProvider.notifier).clear();
    },
  ));

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
