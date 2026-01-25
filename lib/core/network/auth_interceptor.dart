import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_token_provider.dart';

/// Dio interceptor that adds auth token to requests.
///
/// Reads token from [authTokenProvider] (memory) for fast access.
/// Token expiration handling can be added via [onTokenExpired] callback.
class AuthInterceptor extends Interceptor {
  final Ref _ref;
  final void Function()? onTokenExpired;

  AuthInterceptor(this._ref, {this.onTokenExpired});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _ref.read(authTokenProvider);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      onTokenExpired?.call();
    }
    handler.next(err);
  }
}
