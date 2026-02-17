import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vamigo/core/models/token_pair.dart';
import 'package:vamigo/config/environment_config.dart';

part 'auth_service.g.dart';

class AuthService {
  // Use centralized environment configuration
  String get baseUrl => EnvironmentConfig.authBaseUrl;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Sign out
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore Google sign out errors
    }
    await clearAuthStorage();
  }

  /// Clear all auth data from storage
  Future<void> clearAuthStorage() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
    await _storage.delete(key: 'user');
  }

  // Get stored access token for API calls
  Future<String?> getAccessToken() async {
    return await _storage.read(key: 'access_token');
  }

  /// Get both tokens from storage as a TokenPair
  Future<TokenPair?> getTokenPair() async {
    final access = await _storage.read(key: 'access_token');
    final refresh = await _storage.read(key: 'refresh_token');

    if (access != null && refresh != null) {
      return TokenPair(accessToken: access, refreshToken: refresh);
    }

    // Graceful degradation: return access-only pair for migration
    if (access != null) {
      return TokenPair.accessOnly(access);
    }

    return null;
  }

  /// Store both tokens to storage
  Future<void> storeTokenPair(TokenPair pair) async {
    await _storage.write(key: 'access_token', value: pair.accessToken);
    if (pair.hasRefreshToken) {
      await _storage.write(key: 'refresh_token', value: pair.refreshToken);
    }
  }

  /// Refresh tokens using the refresh token.
  ///
  /// Uses http package (NOT Dio) to avoid interceptor recursion.
  /// Returns new TokenPair on success, null on failure.
  Future<TokenPair?> refreshTokens(String refreshToken) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return TokenPair(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
      }
    } catch (e) {
      debugPrint('Token refresh failed: $e');
    }
    return null;
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'access_token');
    return token != null;
  }
}

@Riverpod(keepAlive: true)
AuthService authService(Ref ref) => AuthService();
