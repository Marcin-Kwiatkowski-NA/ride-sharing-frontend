import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:blablafront/core/models/user.dart';
import 'package:blablafront/core/models/token_pair.dart';
import 'package:blablafront/config/environment_config.dart';

class AuthService {
  // Use centralized environment configuration
  String get baseUrl => EnvironmentConfig.authBaseUrl;

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  // Google Sign-In
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Initialize Google Sign-In (required in v7.x)
      await _googleSignIn.initialize();

      // Check if platform supports authenticate
      if (!_googleSignIn.supportsAuthenticate()) {
        return AuthResult.error('Google Sign-In not supported on this platform');
      }

      // Trigger the Google Sign-In flow
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();


      // Get authentication details
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      if (googleAuth.idToken == null) {
        return AuthResult.error('Failed to get ID token from Google');
      }

      // Send ID token to backend for verification
      final response = await http.post(
        Uri.parse('$baseUrl/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'idToken': googleAuth.idToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeAuthResponse(data);
        return AuthResult.success(User.fromJson(data['user']));
      } else {
        return AuthResult.error('Authentication failed: ${response.statusCode}');
      }
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // Register with email/password
  Future<AuthResult> register(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        await _storeAuthResponse(data);
        return AuthResult.success(User.fromJson(data['user']));
      } else if (response.statusCode == 409) {
        return AuthResult.error('An account with this email already exists');
      } else {
        return AuthResult.error('Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  // Traditional login with username/password
  Future<AuthResult> signInWithCredentials(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storeAuthResponse(data);
        return AuthResult.success(User.fromJson(data['user']));
      } else {
        return AuthResult.error('Invalid credentials');
      }
    } catch (e) {
      return AuthResult.error(e.toString());
    }
  }

  /// Store auth response data (tokens and user)
  Future<void> _storeAuthResponse(Map<String, dynamic> data) async {
    // Always store access token
    await _storage.write(key: 'access_token', value: data['accessToken']);

    // Store refresh token if present (graceful degradation)
    if (data['refreshToken'] != null) {
      await _storage.write(key: 'refresh_token', value: data['refreshToken']);
    }

    // Store user data
    await _storage.write(key: 'user', value: jsonEncode(data['user']));
  }

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
        final newPair = TokenPair(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        await storeTokenPair(newPair);
        return newPair;
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

  // Get current user from storage
  Future<User?> getCurrentUser() async {
    final userJson = await _storage.read(key: 'user');
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Get auth headers for API calls
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await getAccessToken();
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}

class AuthResult {
  final bool success;
  final bool cancelled;
  final String? error;
  final User? user;

  AuthResult._({
    required this.success,
    required this.cancelled,
    this.error,
    this.user,
  });

  factory AuthResult.success(User user) =>
      AuthResult._(
        success: true,
        cancelled: false,
        user: user,
      );

  factory AuthResult.error(String message) =>
      AuthResult._(
        success: false,
        cancelled: false,
        error: message,
      );

  factory AuthResult.cancelled() =>
      AuthResult._(
        success: false,
        cancelled: true,
      );
}
