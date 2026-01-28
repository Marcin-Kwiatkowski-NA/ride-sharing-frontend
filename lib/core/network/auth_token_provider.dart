import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/token_pair.dart';

part 'auth_token_provider.g.dart';

/// Riverpod provider that caches the auth token pair in memory for fast access.
///
/// Token pair is synced from FlutterSecureStorage at:
/// 1. App startup - via [loadTokensFromStorage]
/// 2. Login - call [setTokenPair] after writing to storage
/// 3. Logout - call [clear] after clearing storage
/// 4. Token refresh - call [setTokenPair] with new tokens
@Riverpod(keepAlive: true)
class AuthToken extends _$AuthToken {
  @override
  TokenPair? build() => null;

  /// Set the auth token pair in memory
  void setTokenPair(TokenPair? pair) {
    state = pair;
  }

  /// Clear the auth token pair from memory
  void clear() {
    state = null;
  }

  /// Convenience getter for access token (backward compatibility)
  String? get accessToken => state?.accessToken;

  /// Convenience getter for refresh token
  String? get refreshToken => state?.refreshToken;
}

/// Load token pair from secure storage.
/// Call once at app startup before widgets build.
///
/// Returns TokenPair if both tokens exist, or access-only TokenPair for migration,
/// or null if no tokens are stored.
Future<TokenPair?> loadTokensFromStorage() async {
  const storage = FlutterSecureStorage();
  final access = await storage.read(key: 'access_token');
  final refresh = await storage.read(key: 'refresh_token');

  if (access != null && refresh != null) {
    return TokenPair(accessToken: access, refreshToken: refresh);
  }

  // Graceful degradation: if only access token exists (migration case)
  if (access != null) {
    return TokenPair.accessOnly(access);
  }

  return null;
}
