import 'package:flutter/foundation.dart';
import 'package:blablafront/services/auth_service.dart';
import 'package:blablafront/core/models/user.dart';
import 'package:blablafront/core/utils/jwt_decoder.dart';

/// Authentication status enum
enum AuthStatus {
  uninitialized, // App just started, checking for token
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
}

/// Authentication state provider
///
/// Manages global authentication state using Provider pattern.
/// Wraps AuthService and notifies listeners of state changes.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.uninitialized;
  User? _currentUser;
  String? _errorMessage;

  // Getters
  AuthStatus get status => _status;
  User? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isLoading => _status == AuthStatus.uninitialized;

  /// Initialize authentication state
  ///
  /// Called on app startup to check if user is already logged in.
  /// Validates stored token and updates state accordingly.
  Future<void> initialize() async {
    try {
      // Check if token exists
      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        // Validate token expiration
        final token = await _authService.getAccessToken();
        if (token != null && JwtDecoder.isTokenValid(token)) {
          // Token is valid, restore user session
          _currentUser = await _authService.getCurrentUser();
          _status = AuthStatus.authenticated;
        } else {
          // Token expired, clean up
          await _authService.signOut();
          _status = AuthStatus.unauthenticated;
          _errorMessage = 'Your session has expired. Please log in again.';
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = 'Failed to initialize authentication: ${e.toString()}';
    }

    notifyListeners();
  }

  /// Sign in with username and password
  ///
  /// Returns true if sign-in was successful, false otherwise.
  /// Updates authentication state and notifies listeners.
  Future<bool> signInWithCredentials(String username, String password) async {
    _errorMessage = null;
    notifyListeners(); // Show loading state

    try {
      final result = await _authService.signInWithCredentials(username, password);

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else {
        _errorMessage = result.error ?? 'Login failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  /// Sign in with Google
  ///
  /// Returns true if sign-in was successful, false otherwise.
  /// Handles cancellation and errors appropriately.
  Future<bool> signInWithGoogle() async {
    _errorMessage = null;
    notifyListeners(); // Show loading state

    try {
      final result = await _authService.signInWithGoogle();

      if (result.success && result.user != null) {
        _currentUser = result.user;
        _status = AuthStatus.authenticated;
        _errorMessage = null;
        notifyListeners();
        return true;
      } else if (result.cancelled) {
        // User cancelled sign-in, don't show error
        _errorMessage = null;
        notifyListeners();
        return false;
      } else {
        _errorMessage = result.error ?? 'Google sign-in failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
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

    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
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

    _status = AuthStatus.unauthenticated;
    _currentUser = null;
    _errorMessage = 'Your session has expired. Please log in again.';
    notifyListeners();
  }

  /// Refresh user data from storage
  ///
  /// Useful after updating user profile.
  Future<void> refreshUser() async {
    if (_status == AuthStatus.authenticated) {
      try {
        _currentUser = await _authService.getCurrentUser();
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing user: $e');
      }
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
