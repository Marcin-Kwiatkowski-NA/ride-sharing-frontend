import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'auth_notifier.dart';

part 'auth_session_provider.g.dart';

/// Provides a session key that changes ONLY when the user identity changes.
///
/// - Returns `null` when unauthenticated or uninitialized
/// - Returns `userId` when authenticated
///
/// Use this to scope user data providers:
/// ```dart
/// @riverpod
/// Future<List<MyData>> myData(Ref ref) async {
///   final sessionKey = ref.watch(authSessionKeyProvider);
///   if (sessionKey == null) return []; // Not authenticated - no API call
///   return await repository.fetchData();
/// }
/// ```
///
/// Token refresh does NOT change this value (only user login/logout does).
/// AuthState invariant: authenticated implies currentUser != null.
@riverpod
int? authSessionKey(Ref ref) {
  // Watch the auth state and extract userId - only changes when user changes
  // AuthState invariant: authenticated implies currentUser != null
  final authState = ref.watch(authProvider);
  return authState.currentUser?.id;
}
