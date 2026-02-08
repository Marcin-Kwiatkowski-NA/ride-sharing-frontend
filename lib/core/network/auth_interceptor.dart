import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/token_pair.dart';
import 'auth_token_provider.dart';

/// Dio interceptor that handles JWT authentication and token refresh.
///
/// Features:
/// - Adds auth token to outgoing requests
/// - Automatically refreshes tokens on 401 responses
/// - Uses mutex pattern to prevent concurrent refresh calls
/// - Retries failed requests with new token (max 1 retry)
/// - Skips auth for /auth/* endpoints
class AuthInterceptor extends QueuedInterceptor {
  final Ref _ref;
  final Future<TokenPair?> Function(String) _refreshTokens;
  final void Function()? onAuthFailure;

  /// Lock to prevent concurrent refresh calls.
  /// First 401 triggers refresh, subsequent 401s wait for result.
  Completer<TokenPair?>? _refreshLock;

  /// Key to mark requests that have already been retried.
  static const _retriedKey = 'x-retried';

  AuthInterceptor(
    this._ref, {
    required Future<TokenPair?> Function(String) refreshTokens,
    this.onAuthFailure,
  }) : _refreshTokens = refreshTokens;

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip auth for /auth/* endpoints
    if (!_isAuthEndpoint(options.path)) {
      final tokenPair = _ref.read(authTokenProvider);
      if (tokenPair?.accessToken != null && tokenPair!.accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = err.response?.statusCode;
    final path = err.requestOptions.path;

    // 403 = permission issue, pass through (no refresh)
    if (statusCode == 403) {
      return handler.next(err);
    }

    // Skip refresh for auth endpoints
    if (_isAuthEndpoint(path)) {
      return handler.next(err);
    }

    // 401 = try refresh
    if (statusCode == 401) {
      // Already retried? Give up.
      if (err.requestOptions.extra[_retriedKey] == true) {
        onAuthFailure?.call();
        return handler.next(err);
      }

      // Attempt refresh with mutex
      final newTokenPair = await _doRefresh();

      if (newTokenPair != null) {
        // Update memory state
        _ref.read(authTokenProvider.notifier).setTokenPair(newTokenPair);

        // Retry original request
        try {
          final response = await _retryRequest(err.requestOptions, newTokenPair);
          return handler.resolve(response);
        } catch (retryError) {
          // Retry failed, pass through original error
          return handler.next(err);
        }
      } else {
        onAuthFailure?.call();
        return handler.next(err);
      }
    }

    handler.next(err);
  }

  /// Check if path is a public auth endpoint (should skip token handling).
  ///
  /// Only login, register, refresh, and google endpoints are public.
  /// `/auth/me` requires authentication and must NOT be skipped.
  bool _isAuthEndpoint(String path) {
    const publicAuthPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/google',
    ];
    return publicAuthPaths.any((p) => path.contains(p));
  }

  /// Mutex-protected token refresh.
  ///
  /// If a refresh is already in progress, waits for it to complete.
  /// Otherwise, initiates a new refresh.
  Future<TokenPair?> _doRefresh() async {
    // If another request is already refreshing, wait for it
    if (_refreshLock != null) {
      return _refreshLock!.future;
    }

    // Start new refresh
    _refreshLock = Completer<TokenPair?>();

    try {
      final currentPair = _ref.read(authTokenProvider);
      if (currentPair?.refreshToken == null || !currentPair!.hasRefreshToken) {
        _refreshLock!.complete(null);
        return null;
      }

      final newPair = await _refreshTokens(currentPair.refreshToken);
      _refreshLock!.complete(newPair);
      return newPair;
    } catch (e) {
      _refreshLock!.complete(null);
      return null;
    } finally {
      _refreshLock = null;
    }
  }

  /// Retry the original request with new token.
  ///
  /// Uses a fresh Dio instance to avoid interceptor recursion.
  Future<Response> _retryRequest(
    RequestOptions options,
    TokenPair tokenPair,
  ) async {
    options.headers['Authorization'] = 'Bearer ${tokenPair.accessToken}';
    options.extra[_retriedKey] = true;

    // Use fresh Dio instance to avoid interceptor recursion
    final dio = Dio(BaseOptions(baseUrl: options.baseUrl));
    return dio.request(
      options.path,
      data: options.data,
      queryParameters: options.queryParameters,
      options: Options(
        method: options.method,
        headers: options.headers,
        extra: options.extra,
      ),
    );
  }
}
