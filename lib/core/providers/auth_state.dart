import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vamigo/core/models/user_profile.dart';

part 'auth_state.freezed.dart';

/// Authentication status enum
enum AuthStatus {
  /// App just started, checking for token
  uninitialized,
  /// User is logged in
  authenticated,
  /// User is not logged in
  unauthenticated,
}

/// Immutable authentication state
///
/// Uses freezed for immutability and value equality.
/// Replaces the mutable state in the old ChangeNotifier-based AuthProvider.
@freezed
sealed class AuthState with _$AuthState {
  const AuthState._();

  const factory AuthState({
    @Default(AuthStatus.uninitialized) AuthStatus status,
    UserProfile? currentUser,
    String? errorMessage,
  }) = _AuthState;

  /// Whether the user is currently authenticated
  bool get isAuthenticated => status == AuthStatus.authenticated;

  /// Whether the auth state is still being initialized
  bool get isLoading => status == AuthStatus.uninitialized;
}
