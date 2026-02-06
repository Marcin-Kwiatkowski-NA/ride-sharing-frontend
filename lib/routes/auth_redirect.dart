import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_notifier.dart';
import '../core/providers/auth_state.dart';
import 'routes.dart';

/// Public routes that don't require authentication
const _publicPaths = {
  RoutePaths.splash,
  RoutePaths.login,
  RoutePaths.createAccount,
  RoutePaths.rides,
  RoutePaths.packages,
};

/// Check if path requires auth (protected by default, except explicit public paths)
bool _isPublicPath(String path) {
  if (_publicPaths.contains(path)) return true;
  // /rides is public, sub-routes like /rides/list and /rides/passengers-placeholder too
  if (path == '/rides') return true;
  if (path.startsWith('/rides/list')) return true;
  if (path.startsWith('/rides/passengers-placeholder')) return true;
  if (path == '/packages') return true;
  return false;
}

/// Global redirect logic for auth gating
String? authRedirect(Ref ref, GoRouterState state) {
  final authState = ref.read(authProvider);
  final currentPath = state.uri.path;
  final isOnSplash = currentPath == RoutePaths.splash;
  final isOnAuthPage =
      currentPath == RoutePaths.login || currentPath == RoutePaths.createAccount;

  // Still initializing - redirect to splash (unless already there)
  if (authState.status == AuthStatus.uninitialized) {
    return isOnSplash ? null : RoutePaths.splash;
  }

  // Done initializing but on splash - redirect to rides (home)
  if (isOnSplash) {
    return RoutePaths.rides;
  }

  final isAuthenticated = authState.isAuthenticated;
  final isPublic = _isPublicPath(currentPath);

  // Not authenticated trying to access protected route
  if (!isAuthenticated && !isPublic) {
    // Use namedLocation to build URL - go_router handles encoding
    // 'back' provides fallback for back button when there's no back stack (deep links)
    return state.namedLocation(
      RouteNames.login,
      queryParameters: {'from': state.uri.toString(), 'back': '/rides'},
    );
  }

  // Authenticated but on login/create-account
  if (isAuthenticated && isOnAuthPage) {
    final from = state.uri.queryParameters['from'];
    // Validate 'from' to prevent open redirects - must be internal path
    if (from != null && from.startsWith('/')) {
      return from;
    }
    return RoutePaths.rides;
  }

  return null;
}

/// Listenable that notifies GoRouter when auth state changes.
/// Listens to both status and isAuthenticated to catch logout, token refresh, account switch.
class AuthRefreshListenable extends ChangeNotifier {
  AuthRefreshListenable(Ref ref) {
    _subscription = ref.listen(authProvider, (previous, next) {
      // Notify on any auth-relevant change: status OR authentication state
      final statusChanged = previous?.status != next.status;
      final authChanged = previous?.isAuthenticated != next.isAuthenticated;
      if (statusChanged || authChanged) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription<AuthState> _subscription;

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}
