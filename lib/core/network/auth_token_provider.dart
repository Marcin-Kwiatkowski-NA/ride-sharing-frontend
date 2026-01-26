import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_token_provider.g.dart';

/// Riverpod provider that caches the auth token in memory for fast access.
///
/// Token is synced from FlutterSecureStorage at:
/// 1. App startup - via [initializeAuthToken]
/// 2. Login - call [setToken] after writing to storage
/// 3. Logout - call [setToken(null)] after clearing storage
@Riverpod(keepAlive: true)
class AuthToken extends _$AuthToken {
  @override
  String? build() => null;

  /// Set the auth token in memory
  void setToken(String? token) {
    state = token;
  }
}

/// Initialize auth token from secure storage.
/// Call once at app startup before widgets build.
Future<String?> loadTokenFromStorage() async {
  const storage = FlutterSecureStorage();
  return await storage.read(key: 'access_token');
}
