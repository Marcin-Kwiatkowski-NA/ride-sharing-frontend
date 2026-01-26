import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:blablafront/services/auth_service.dart';
import 'package:blablafront/core/utils/jwt_decoder.dart';
import 'package:blablafront/core/network/auth_token_provider.dart';
import 'auth_state.dart';

part 'auth_notifier.g.dart';

/// Authentication notifier using Riverpod 3.0 code generation
///
/// Manages global authentication state. Uses `keepAlive: true` to persist
/// the auth state for the lifetime of the app.
@Riverpod(keepAlive: true)
class Auth extends _$Auth {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = AuthService();
    // Initialize auth state asynchronously
    Future.microtask(() => _initialize());
    return const AuthState();
  }

  /// Initialize authentication state
  ///
  /// Called on app startup to check if user is already logged in.
  /// Validates stored token and updates state accordingly.
  Future<void> _initialize() async {
    try {
      // Check if token exists
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Validate token expiration
        final token = await _authService.getAccessToken();
        if (token != null && JwtDecoder.isTokenValid(token)) {
          // Token is valid, restore user session
          final user = await _authService.getCurrentUser();
          // Sync token to authTokenProvider
          ref.read(authTokenProvider.notifier).setToken(token);

          if (!ref.mounted) return;
          state = AuthState(
            status: AuthStatus.authenticated,
            currentUser: user,
          );
        } else {
          // Token expired, clean up
          await _authService.signOut();
          ref.read(authTokenProvider.notifier).setToken(null);

          if (!ref.mounted) return;
          state = const AuthState(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Your session has expired. Please log in again.',
          );
        }
      } else {
        if (!ref.mounted) return;
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      if (!ref.mounted) return;
      state = AuthState(
        status: AuthStatus.unauthenticated,
        errorMessage: 'Failed to initialize authentication: ${e.toString()}',
      );
    }
  }

  /// Sign in with username and password
  ///
  /// Returns true if sign-in was successful, false otherwise.
  Future<bool> signInWithCredentials(String username, String password) async {
    // Clear previous error
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _authService.signInWithCredentials(username, password);

      if (!ref.mounted) return false;

      if (result.success && result.user != null) {
        // Sync token to authTokenProvider
        final token = await _authService.getAccessToken();
        ref.read(authTokenProvider.notifier).setToken(token);

        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: result.user,
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: result.error ?? 'Login failed',
        );
        return false;
      }
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        errorMessage: 'An error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  /// Register with email and password
  ///
  /// Returns true if registration was successful, false otherwise.
  Future<bool> register(String email, String password) async {
    // Clear previous error
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _authService.register(email, password);

      if (!ref.mounted) return false;

      if (result.success && result.user != null) {
        // Sync token to authTokenProvider
        final token = await _authService.getAccessToken();
        ref.read(authTokenProvider.notifier).setToken(token);

        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: result.user,
        );
        return true;
      } else {
        state = state.copyWith(
          errorMessage: result.error ?? 'Registration failed',
        );
        return false;
      }
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        errorMessage: 'An error occurred: ${e.toString()}',
      );
      return false;
    }
  }

  /// Sign in with Google
  ///
  /// Returns true if sign-in was successful, false otherwise.
  /// Handles cancellation and errors appropriately.
  Future<bool> signInWithGoogle() async {
    // Clear previous error
    state = state.copyWith(errorMessage: null);

    try {
      final result = await _authService.signInWithGoogle();

      if (!ref.mounted) return false;

      if (result.success && result.user != null) {
        // Sync token to authTokenProvider
        final token = await _authService.getAccessToken();
        ref.read(authTokenProvider.notifier).setToken(token);

        state = AuthState(
          status: AuthStatus.authenticated,
          currentUser: result.user,
        );
        return true;
      } else if (result.cancelled) {
        // User cancelled sign-in, don't show error
        return false;
      } else {
        state = state.copyWith(
          errorMessage: result.error ?? 'Google sign-in failed',
        );
        return false;
      }
    } catch (e) {
      if (!ref.mounted) return false;
      state = state.copyWith(
        errorMessage: 'An error occurred: ${e.toString()}',
      );
      return false;
    }
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
    ref.read(authTokenProvider.notifier).setToken(null);

    if (!ref.mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
    );
  }

  /// Handle token expiration
  ///
  /// Called when API client detects an expired token (401 response).
  /// Clears authentication state and notifies user.
  Future<void> handleTokenExpiration() async {
    try {
      await _authService.signOut();
    } catch (e) {
      debugPrint('Error cleaning up expired session: $e');
    }

    // Clear token from memory
    ref.read(authTokenProvider.notifier).setToken(null);

    if (!ref.mounted) return;
    state = const AuthState(
      status: AuthStatus.unauthenticated,
      errorMessage: 'Your session has expired. Please log in again.',
    );
  }

  /// Refresh user data from storage
  ///
  /// Useful after updating user profile.
  Future<void> refreshUser() async {
    if (state.status == AuthStatus.authenticated) {
      try {
        final user = await _authService.getCurrentUser();
        if (!ref.mounted) return;
        state = state.copyWith(currentUser: user);
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
