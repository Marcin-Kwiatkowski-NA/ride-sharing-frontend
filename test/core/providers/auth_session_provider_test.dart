import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:blablafront/core/providers/auth_notifier.dart';
import 'package:blablafront/core/providers/auth_state.dart';
import 'package:blablafront/core/providers/auth_session_provider.dart';
import 'package:blablafront/core/models/user_profile.dart';
import 'package:blablafront/core/models/account_status.dart';
import 'package:blablafront/core/models/user_stats.dart';

void main() {
  group('authSessionKeyProvider', () {
    test('returns null when unauthenticated', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            const AuthState(status: AuthStatus.unauthenticated),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sessionKey = container.read(authSessionKeyProvider);
      expect(sessionKey, isNull);
    });

    test('returns null when uninitialized', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(const AuthState()),
        ],
      );
      addTearDown(container.dispose);

      // Default state is uninitialized
      final sessionKey = container.read(authSessionKeyProvider);
      expect(sessionKey, isNull);
    });

    test('returns userId when authenticated', () {
      final container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            AuthState(
              status: AuthStatus.authenticated,
              currentUser: UserProfile(
                id: 42,
                email: 'test42@example.com',
                displayName: 'Test User 42',
                status: AccountStatus.active,
                stats: const UserStats(),
              ),
            ),
          ),
        ],
      );
      addTearDown(container.dispose);

      final sessionKey = container.read(authSessionKeyProvider);
      expect(sessionKey, 42);
    });

    test('returns different userId for different users', () {
      // User 1
      var container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            AuthState(
              status: AuthStatus.authenticated,
              currentUser: UserProfile(
                id: 1,
                email: 'test1@example.com',
                displayName: 'Test User 1',
                status: AccountStatus.active,
                stats: const UserStats(),
              ),
            ),
          ),
        ],
      );
      expect(container.read(authSessionKeyProvider), 1);
      container.dispose();

      // User 2
      container = ProviderContainer(
        overrides: [
          authProvider.overrideWithValue(
            AuthState(
              status: AuthStatus.authenticated,
              currentUser: UserProfile(
                id: 2,
                email: 'test2@example.com',
                displayName: 'Test User 2',
                status: AccountStatus.active,
                stats: const UserStats(),
              ),
            ),
          ),
        ],
      );
      expect(container.read(authSessionKeyProvider), 2);
      container.dispose();
    });
  });
}
