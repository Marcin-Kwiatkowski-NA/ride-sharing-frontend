import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blablafront/services/auth_service.dart';
import 'package:blablafront/core/utils/jwt_decoder.dart';
import 'package:blablafront/core/network/auth_token_provider.dart';
import 'package:blablafront/core/models/token_pair.dart';
import 'package:blablafront/features/auth/data/auth_repository.dart';
import 'package:blablafront/features/auth/data/dtos/login_request.dart';
import 'package:blablafront/features/auth/data/dtos/register_request.dart';
import 'package:blablafront/features/profile/data/profile_repository.dart';
import 'package:blablafront/features/profile/data/dtos/update_profile_request.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Authentication notifier using Riverpod 3.0 code generation
///
/// Manages global authentication state. Uses `keepAlive: true` to persist
/// the auth state for the lifetime of the app.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthService _authService;
  late final IAuthRepository _authRepository;
  late final IProfileRepository _profileRepository;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _authRepository = ref.watch(authRepositoryProvider);
    _profileRepository = ref.watch(profileRepositoryProvider);
    // Initialize auth state asynchronously
    Future.microtask(() => _initialize());
    return const AuthState();
  }

  /// Initialize authentication state
  ///
  /// Called on app startup to check if user is already logged in.
  /// Validates stored token and hydrates user profile from API.
  Future<void> _initialize() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (!isLoggedIn) {
        if (!ref.mounted) return;
        state = const AuthState(status: AuthStatus.unauthenticated);
        return;
      }

      final token = await _authService.getAccessToken();
      TokenPair? tokenPair = await _authService.getTokenPair();

      if (token == null || !JwtDecoder.isTokenValid(token)) {
        // Access token expired - try refreshing with refresh token
        if (tokenPair != null && tokenPair.hasRefreshToken) {
          final refreshed = await _authService.refreshTokens(
            tokenPair.refreshToken,
          );
          if (refreshed != null) {
            tokenPair = refreshed;
          } else {
            // Refresh failed - clear and log out
            await _authService.clearAuthStorage();
            ref.read(authTokenProvider.notifier).clear();
            if (!ref.mounted) return;
            state = const AuthState(
              status: AuthStatus.unauthenticated,
              errorMessage: 'Your session has expired. Please log in again.',
            );
            return;
          }
        } else {
          // No refresh token available
          await _authService.clearAuthStorage();
          ref.read(authTokenProvider.notifier).clear();
          if (!ref.mounted) return;
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Your session has expired. Please log in again.',
          );
          return;
        }
      }

      // Sync valid tokens to memory
      ref.read(authTokenProvider.notifier).setTokenPair(tokenPair);

      // Hydrate user from API
      try {
        final userProfile = await _authRepository.me();
        if (!ref.mounted) return;
        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: userProfile,
        );
      } on DioException catch (e) {
        if (!ref.mounted) return;
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          // Session invalid on server - clear everything
          await _authService.clearAuthStorage();
          ref.read(authTokenProvider.notifier).clear();
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Your session is invalid. Please log in again.',
          );
        } else {
          // Network/other error - stay unauthenticated but keep tokens for retry
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Could not load profile. Please try again.',
          );
        }
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Failed to initialize: ${e.toString()}',
      );
    }
  }

  /// Sign in with email and password
  ///
  /// Returns true if sign-in was successful, false otherwise.
  Future<bool> signInWithEmail(String email, String password) async {
    // Clear previous error
    state = state.copyWith(errorMessage: null);

    try {
      final request = LoginRequest(email: email, password: password);
      final response = await _authRepository.login(request);

      final tokenPair = TokenPair(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _authService.storeTokenPair(tokenPair);
      ref.read(authTokenProvider.notifier).setTokenPair(tokenPair);

      if (!ref.mounted) return false;
      state = AuthState(
        status: AuthStatus.authenticated,
        currentUser: response.user,
      );
      return true;
    } on DioException catch (e) {
      if (!ref.mounted) return false;
      final message = _extractErrorMessage(e, 'Invalid credentials');
      state = state.copyWith(errorMessage: message);
      return false;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Register with email, password, and display name
  ///
  /// Returns true if registration was successful, false otherwise.
  Future<bool> register(String email, String password, String displayName) async {
    // Clear previous error
    state = state.copyWith(errorMessage: null);

    try {
      final request = RegisterRequest(
        email: email,
        password: password,
        displayName: displayName,
      );
      final response = await _authRepository.register(request);

      final tokenPair = TokenPair(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
      );
      await _authService.storeTokenPair(tokenPair);
      ref.read(authTokenProvider.notifier).setTokenPair(tokenPair);

      if (!ref.mounted) return false;
      state = AuthState(
        status: AuthStatus.authenticated,
        currentUser: response.user,
      );
      return true;
    } on DioException catch (e) {
      if (!ref.mounted) return false;
      String message = 'Registration failed';
      if (e.response?.statusCode == 409) {
        message = 'An account with this email already exists';
      } else {
        message = _extractErrorMessage(e, message);
      }
      state = state.copyWith(errorMessage: message);
      return false;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Google Sign-In - NOT IMPLEMENTED in Stage 2
  ///
  /// Returns false and shows "not available" message.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(
      errorMessage: 'Google Sign-In is not available yet.',
    );
    return false;
  }

  /// Sign out current user
  ///
  /// Clears all user data and authentication state.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      // Log error but continue with local cleanup
      debugPrint('Error during sign out: $e');
    }

    // Clear token from memory
    ref.read(authTokenProvider.notifier).clear();

    if (!ref.mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  /// Handle token expiration
  ///
  /// Called when API client detects an expired token after refresh failure.
  /// Clears authentication state and notifies user.
  Future<void> handleTokenExpiration() async {
    try {
      await _authService.clearAuthStorage();
    } catch (e) {
      debugPrint('Error cleaning up expired session: $e');
    }

    // Clear token from memory
    ref.read(authTokenProvider.notifier).clear();

    if (!ref.mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Your session has expired. Please log in again.',
    );
  }

  /// Refresh user data from API
  ///
  /// Useful after updating user profile.
  Future<void> refreshUser() async {
    if (state.status == AuthStatus.authenticated) {
      try {
        final userProfile = await _authRepository.me();
        if (!ref.mounted) return;
        state = state.copyWith(currentUser: userProfile);
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }

  /// Update user profile
  ///
  /// Returns true if update was successful, false otherwise.
  Future<bool> updateProfile({
    String? displayName,
    String? bio,
    String? phoneNumber,
  }) async {
    state = state.copyWith(errorMessage: null);

    try {
      final request = UpdateProfileRequest(
        displayName: displayName,
        bio: bio,
        phoneNumber: phoneNumber,
      );
      final updatedUser = await _profileRepository.updateProfile(request);

      if (!ref.mounted) return false;
      state = state.copyWith(currentUser: updatedUser);
      return true;
    } on DioException catch (e) {
      if (!ref.mounted) return false;
      final message = _extractErrorMessage(e, 'Failed to update profile');
      state = state.copyWith(errorMessage: message);
      return false;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Extract error message from DioException
  String _extractErrorMessage(DioException e, String defaultMessage) {
    final data = e.response?.data;
    if (data is Map<String, dynamic> && data.containsKey('message')) {
      return data['message'] as String;
    }
    return defaultMessage;
  }
}
