import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Riverpod provider that caches the auth token in memory for fast access.
///
/// Token is synced from FlutterSecureStorage at:
/// 1. App startup - via [initializeAuthToken]
/// 2. Login - call [updateAuthToken] after writing to storage
/// 3. Logout - call [clearAuthToken] after clearing storage
final authTokenProvider = StateProvider<String?>((ref) => null);

/// Initialize auth token from secure storage.
/// Call once at app startup.
Future<void> initializeAuthToken(ProviderContainer container) async {
  const storage = FlutterSecureStorage();
  final token = await storage.read(key: 'access_token');
  container.read(authTokenProvider.notifier).state = token;
}

/// Update auth token after login.
/// Call after writing token to secure storage.
void updateAuthToken(ProviderContainer container, String token) {
  container.read(authTokenProvider.notifier).state = token;
}

/// Clear auth token on logout.
/// Call after clearing secure storage.
void clearAuthToken(ProviderContainer container) {
  container.read(authTokenProvider.notifier).state = null;
}
