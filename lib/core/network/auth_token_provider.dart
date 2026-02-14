import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../services/auth_service.dart';
import '../models/token_pair.dart';

part 'auth_token_provider.g.dart';

/// Single authority for token lifecycle: in-memory cache + secure storage.
///
/// All token mutations go through this notifier. It delegates persistent
/// storage operations to [AuthService] internally.
///
/// - [hydrate]: startup only — loads tokens into memory without re-writing storage
/// - [setTokenPair]: updates memory + writes to secure storage
/// - [clear]: clears memory + clears secure storage
@Riverpod(keepAlive: true)
class AuthToken extends _$AuthToken {
  @override
  TokenPair? build() => null;

  /// Startup hydration — sets memory state only (tokens are already in storage).
  void hydrate(TokenPair? pair) => state = pair;

  /// Set tokens: updates memory + writes to secure storage.
  void setTokenPair(TokenPair? pair) {
    state = pair;
    if (pair != null) {
      ref.read(authServiceProvider).storeTokenPair(pair);
    }
  }

  /// Clear tokens: clears memory + clears secure storage.
  void clear() {
    state = null;
    ref.read(authServiceProvider).clearAuthStorage();
  }
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
