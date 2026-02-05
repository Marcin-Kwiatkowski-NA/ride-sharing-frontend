import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../features/auth/presentation/screens/create_account_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/tabs/messages_tab.dart';
import '../features/navigation/main_layout.dart';
import '../features/passengers/presentation/screens/search_passenger_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/rides/create/presentation/post_ride_screen.dart';
import '../features/rides/presentation/screens/ride_details_screen.dart';
import '../features/rides/presentation/screens/search_ride_screen.dart';
import 'auth_redirect.dart';
import 'error_screen.dart';
import 'routes.dart';
import 'splash_screen.dart';

part 'router_config.g.dart';

// Navigator key for root navigator (routes above tabs)
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refreshListenable = AuthRefreshListenable(ref);

  // Dispose the listenable when provider is disposed
  ref.onDispose(() {
    refreshListenable.dispose();
  });

  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.rides,
    debugLogDiagnostics: true,
    refreshListenable: refreshListenable,
    redirect: (context, state) => authRedirect(ref, state),
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
    routes: [
      // Root redirect
      GoRoute(
        path: RoutePaths.root,
        redirect: (context, state) => RoutePaths.rides,
      ),

      // Splash (shown during token init)
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // Public auth routes
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) {
          // 'from' is validated in redirect (must start with /) - safe to use
          final from = state.uri.queryParameters['from'];
          final back = state.uri.queryParameters['back'];
          return LoginScreen(returnTo: from, backTo: back);
        },
      ),
      GoRoute(
        path: RoutePaths.createAccount,
        name: RouteNames.createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),

      // Shell for bottom navigation tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Rides
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.rides,
                name: RouteNames.rides,
                builder: (context, state) => const SearchRideScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.rideDetails,
                    name: RouteNames.rideDetails,
                    // Redirect invalid params - let errorBuilder handle display
                    redirect: (context, state) {
                      final rideIdStr = state.pathParameters['rideId']!;
                      if (int.tryParse(rideIdStr) == null) {
                        return RoutePaths.rides; // Redirect to safe location
                      }
                      return null;
                    },
                    builder: (context, state) {
                      final rideId = int.parse(state.pathParameters['rideId']!);
                      return RideDetailsScreen(rideId: rideId);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Passengers
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.passengers,
                name: RouteNames.passengers,
                builder: (context, state) => const SearchPassengerScreen(),
              ),
            ],
          ),

          // Branch 2: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                name: RouteNames.profile,
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.editProfile,
                    name: RouteNames.editProfile,
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Messages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.messages,
                name: RouteNames.messages,
                builder: (context, state) => const MessagesTab(),
              ),
            ],
          ),
        ],
      ),

      // Global routes (above tabs, use root navigator)
      GoRoute(
        path: RoutePaths.chat,
        name: RouteNames.chat,
        parentNavigatorKey: _rootNavigatorKey, // Full screen above tabs
        // Redirect invalid params to messages tab
        redirect: (context, state) {
          final idStr = state.pathParameters['conversationId'];
          if (idStr == null || idStr.isEmpty) {
            return RoutePaths.messages;
          }
          return null;
        },
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId']!;
          return ChatScreen(conversationId: conversationId);
        },
      ),
      GoRoute(
        path: RoutePaths.postRide,
        name: RouteNames.postRide,
        parentNavigatorKey: _rootNavigatorKey, // Full screen above tabs
        builder: (context, state) => const PostRideScreen(),
      ),
    ],
  );

  // Dispose router when provider is disposed
  ref.onDispose(() {
    router.dispose();
  });

  return router;
}
