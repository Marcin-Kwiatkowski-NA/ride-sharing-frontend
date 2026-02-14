import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blablafront/core/providers/auth_notifier.dart';
import 'package:blablafront/core/providers/auth_state.dart';
import 'package:blablafront/core/models/user_profile.dart';
import 'package:blablafront/core/models/auth_response.dart';
import 'package:blablafront/core/models/account_status.dart';
import 'package:blablafront/core/models/user_stats.dart';
import 'package:blablafront/core/models/token_pair.dart';
import 'package:blablafront/features/auth/data/auth_repository.dart';
import 'package:blablafront/features/auth/data/dtos/login_request.dart';
import 'package:blablafront/features/auth/data/dtos/register_request.dart';
import 'package:blablafront/features/auth/data/dtos/refresh_token_request.dart';
import 'package:blablafront/services/auth_service.dart';

class FakeAuthRepository implements IAuthRepository {
  AuthResponse? loginResponse;
  AuthResponse? registerResponse;
  UserProfile? meResponse;
  Exception? loginError;
  Exception? registerError;
  Exception? meError;

  @override
  Future<AuthResponse> login(LoginRequest request) async {
    if (loginError != null) throw loginError!;
    return loginResponse!;
  }

  @override
  Future<AuthResponse> register(RegisterRequest request) async {
    if (registerError != null) throw registerError!;
    return registerResponse!;
  }

  @override
  Future<UserProfile> me(String accessToken) async {
    if (meError != null) throw meError!;
    return meResponse!;
  }

  @override
  Future<AuthResponse> refresh(RefreshTokenRequest request) async {
    throw UnimplementedError();
  }
}

class FakeAuthService extends AuthService {
  bool _isLoggedIn = false;
  String? _accessToken;
  TokenPair? _tokenPair;

  void setLoggedIn(bool value, {String? token}) {
    _isLoggedIn = value;
    _accessToken = token;
  }

  @override
  Future<bool> isLoggedIn() async => _isLoggedIn;

  @override
  Future<String?> getAccessToken() async => _accessToken;

  @override
  Future<TokenPair?> getTokenPair() async => _tokenPair;

  @override
  Future<void> storeTokenPair(TokenPair pair) async {
    _tokenPair = pair;
    _accessToken = pair.accessToken;
    _isLoggedIn = true;
  }

  @override
  Future<void> clearAuthStorage() async {
    _isLoggedIn = false;
    _accessToken = null;
    _tokenPair = null;
  }

  @override
  Future<void> signOut() async {
    await clearAuthStorage();
  }
}

void main() {
  final testUserProfile = UserProfile(
    id: 1,
    email: 'test@example.com',
    status: AccountStatus.active,
    displayName: 'Test User',
    stats: const UserStats(),
  );

  final testAuthResponse = AuthResponse(
    accessToken: 'test-access-token',
    refreshToken: 'test-refresh-token',
    expiresIn: 3600,
    refreshExpiresIn: 86400,
    user: testUserProfile,
  );

  group('AuthNotifier', () {
    test('login success sets authenticated state with user', () async {
      final fakeRepo = FakeAuthRepository()..loginResponse = testAuthResponse;
      final fakeAuthService = FakeAuthService();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Read provider to trigger build(), then wait for initialization
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(authProvider.notifier);
      final success = await notifier.signInWithEmail('test@example.com', 'password');

      expect(success, isTrue);
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(authProvider).currentUser, testUserProfile);
    });

    test('login failure sets error message', () async {
      final fakeRepo = FakeAuthRepository()..loginError = Exception('Network error');
      final fakeAuthService = FakeAuthService();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Read provider to trigger build(), then wait for initialization
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(authProvider.notifier);
      final success = await notifier.signInWithEmail('test@example.com', 'password');

      expect(success, isFalse);
      expect(container.read(authProvider).errorMessage, isNotNull);
    });

    test('register success sets authenticated state with user', () async {
      final fakeRepo = FakeAuthRepository()..registerResponse = testAuthResponse;
      final fakeAuthService = FakeAuthService();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Read provider to trigger build(), then wait for initialization
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(authProvider.notifier);
      final success = await notifier.register('test@example.com', 'password', 'Test User');

      expect(success, isTrue);
      expect(container.read(authProvider).status, AuthStatus.authenticated);
      expect(container.read(authProvider).currentUser, testUserProfile);
    });

    test('signInWithGoogle returns false with not available message', () async {
      final fakeRepo = FakeAuthRepository();
      final fakeAuthService = FakeAuthService();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Read provider to trigger build(), then wait for initialization
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(authProvider.notifier);
      final success = await notifier.signInWithGoogle();

      expect(success, isFalse);
      expect(container.read(authProvider).errorMessage, 'Google Sign-In is not available yet.');
    });

    test('signOut clears authentication state', () async {
      final fakeRepo = FakeAuthRepository()..loginResponse = testAuthResponse;
      final fakeAuthService = FakeAuthService();

      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(fakeRepo),
          authServiceProvider.overrideWithValue(fakeAuthService),
        ],
      );
      addTearDown(container.dispose);

      // Read provider to trigger build(), then wait for initialization
      container.read(authProvider);
      await Future.delayed(Duration.zero);

      final notifier = container.read(authProvider.notifier);

      // First login
      await notifier.signInWithEmail('test@example.com', 'password');
      expect(container.read(authProvider).status, AuthStatus.authenticated);

      // Then logout
      await notifier.signOut();
      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      expect(container.read(authProvider).currentUser, isNull);
    });
  });
}
