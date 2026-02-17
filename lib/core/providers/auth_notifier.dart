import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:vamigo/services/auth_service.dart';
import 'package:vamigo/core/utils/jwt_decoder.dart';
import 'package:vamigo/core/network/auth_token_provider.dart';
import 'package:vamigo/core/network/dio_provider.dart';
import 'package:vamigo/core/models/token_pair.dart';
import 'package:vamigo/features/auth/data/auth_repository.dart';
import 'package:vamigo/features/auth/data/dtos/login_request.dart';
import 'package:vamigo/features/auth/data/dtos/register_request.dart';
import 'package:vamigo/features/profile/data/profile_repository.dart';
import 'package:vamigo/features/profile/data/dtos/update_profile_request.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Authentication notifier using Riverpod 3.0 code generation
///
/// Manages global authentication state. Uses `keepAlive: true` to persist
/// the auth state for the lifetime of the app.
///
/// Token persistence is delegated entirely to [authTokenProvider] (single authority).
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthService _authService;
  late final IAuthRepository _authRepository;

  @override
  AuthState build() {
    _authService = ref.watch(authServiceProvider);
    _authRepository = ref.watch(authRepositoryProvider);
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
          ref.read(authTokenProvider.notifier).clear();
          if (!ref.mounted) return;
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Your session has expired. Please log in again.',
          );
          return;
        }
      }

      // Sync valid tokens to memory + storage (handles refreshed case)
      ref.read(authTokenProvider.notifier).setTokenPair(tokenPair);

      // Hydrate user from API (manual token injection via rawDio)
      try {
        final userProfile = await _authRepository.me(tokenPair!.accessToken);
        if (!ref.mounted) return;
        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: userProfile,
        );
      } on DioException catch (e) {
        if (!ref.mounted) return;
        if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
          // Session invalid on server - clear everything
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

  /// Delete current user's account permanently.
  ///
  /// Calls the backend DELETE /me, then clears local session.
  /// Returns true on success, false on error.
  Future<bool> deleteAccount() async {
    try {
      final profileRepo = ref.read(profileRepositoryProvider);
      await profileRepo.deleteAccount();

      // Clear local session (same as signOut)
      ref.read(authTokenProvider.notifier).clear();
      if (!ref.mounted) return false;
      state = const AuthState(status: AuthStatus.unauthenticated);
      return true;
    } on DioException catch (e) {
      if (!ref.mounted) return false;
      final message = _extractErrorMessage(e, 'Failed to delete account');
      state = state.copyWith(errorMessage: message);
      return false;
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(errorMessage: 'An error occurred: ${e.toString()}');
      return false;
    }
  }

  /// Sign out current user
  ///
  /// Clears all user data and authentication state.
  /// Google sign out is handled by AuthService; token cleanup by authTokenProvider.
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } catch (e) {
      // Log error but continue with local cleanup
      debugPrint('Error during sign out: $e');
    }

    // Single authority clears both memory and storage
    ref.read(authTokenProvider.notifier).clear();

    if (!ref.mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  /// Called by the UI auth coordinator when the token store is externally
  /// cleared (e.g. by the Dio interceptor on unrecoverable auth failure).
  void onSessionExpired() {
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
      final tokenPair = ref.read(authTokenProvider);
      if (tokenPair == null) return;
      try {
        final userProfile = await _authRepository.me(tokenPair.accessToken);
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
      final profileRepo = ref.read(profileRepositoryProvider);
      final updatedUser = await profileRepo.updateProfile(request);

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

  /// Resend email verification.
  ///
  /// Returns a [ResendResult] indicating success, already-verified (409),
  /// rate-limited (429) with cooldown seconds, or generic error.
  Future<ResendResult> resendVerification() async {
    try {
      final dio = ref.read(apiDioProvider);
      await dio.post<void>('/auth/resend-verification');
      return const ResendResult.success();
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      if (status == 409) {
        // Already verified — refresh user to update badge
        await refreshUser();
        return const ResendResult.alreadyVerified();
      }
      if (status == 429) {
        final data = e.response?.data;
        int cooldown = 60;
        if (data is Map<String, dynamic>) {
          final detail = data['detail'] ?? data['message'];
          if (detail is String) {
            final match = RegExp(r'(\d+)').firstMatch(detail);
            if (match != null) {
              cooldown = int.parse(match.group(1)!);
            }
          } else if (data['cooldownSeconds'] is int) {
            cooldown = data['cooldownSeconds'] as int;
          }
        }
        return ResendResult.cooldown(cooldown);
      }
      return const ResendResult.error();
    } catch (_) {
      return const ResendResult.error();
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

/// Result of a resend-verification API call.
sealed class ResendResult {
  const ResendResult();
  const factory ResendResult.success() = ResendSuccess;
  const factory ResendResult.alreadyVerified() = ResendAlreadyVerified;
  const factory ResendResult.cooldown(int seconds) = ResendCooldown;
  const factory ResendResult.error() = ResendError;
}

class ResendSuccess extends ResendResult {
  const ResendSuccess();
}

class ResendAlreadyVerified extends ResendResult {
  const ResendAlreadyVerified();
}

class ResendCooldown extends ResendResult {
  final int seconds;
  const ResendCooldown(this.seconds);
}

class ResendError extends ResendResult {
  const ResendError();
}
