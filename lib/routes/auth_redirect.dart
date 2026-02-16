import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/auth_notifier.dart';
import '../core/providers/auth_state.dart';
import '../features/rides/presentation/providers/search_mode_provider.dart';
import 'routes.dart';

/// Public routes that don't require authentication
const _publicPaths = {
  RoutePaths.splash,
  RoutePaths.login,
  RoutePaths.createAccount,
  RoutePaths.rides,
  RoutePaths.packages,
  RoutePaths.verifyResult,
};

/// Check if path requires auth (protected by default, except explicit public paths)
bool _isPublicPath(String path) {
  if (_publicPaths.contains(path)) return true;
  if (path == '/rides') return true;
  if (path.startsWith('/rides/list')) return true;
  if (path.startsWith('/rides/seats')) return true;
  if (path == '/packages') return true;
  return false;
}

/// Global redirect logic for auth gating.
///
/// Auth-only — no search mode logic here. Mode-based navigation
/// is handled by route-level redirects in router_config.dart.
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
    return state.namedLocation(
      RouteNames.login,
      queryParameters: {'from': state.uri.toString(), 'back': '/rides'},
    );
  }

  // Authenticated but on login/create-account
  if (isAuthenticated && isOnAuthPage) {
    final from = state.uri.queryParameters['from'];
    if (from != null && from.startsWith('/')) {
      return from;
    }
    return RoutePaths.rides;
  }

  return null;
}

/// Listenable that notifies GoRouter when auth or search mode state changes.
///
/// Triggers router refresh (re-runs redirects) on:
/// - Auth status changes (login/logout/token init)
/// - Search mode changes (rides ↔ passengers)
class RouterRefreshListenable extends ChangeNotifier {
  RouterRefreshListenable(Ref ref) {
    _authSub = ref.listen(authProvider, (previous, next) {
      final statusChanged = previous?.status != next.status;
      final authChanged = previous?.isAuthenticated != next.isAuthenticated;
      if (statusChanged || authChanged) {
        notifyListeners();
      }
    });
    _modeSub = ref.listen(searchModeProvider, (previous, next) {
      if (previous != next) {
        notifyListeners();
      }
    });
  }

  late final ProviderSubscription<AuthState> _authSub;
  late final ProviderSubscription<SearchMode> _modeSub;

  @override
  void dispose() {
    _authSub.close();
    _modeSub.close();
    super.dispose();
  }
}
