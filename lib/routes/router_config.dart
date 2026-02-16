import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/locations/domain/location.dart';
import '../features/auth/presentation/screens/create_account_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/verify_result_screen.dart';
import '../features/chat/presentation/screens/chat_screen.dart';
import '../features/chat/presentation/tabs/messages_tab.dart';
import '../features/navigation/main_layout.dart';
import '../features/offers/domain/offer_ui_model.dart';
import '../core/theme/component_gallery_screen.dart';
import '../features/offers/presentation/screens/my_offers_screen.dart';
import '../features/offers/presentation/screens/offer_details_screen.dart';
import '../features/packages/presentation/screens/packages_screen.dart';
import '../features/profile/presentation/screens/edit_profile_screen.dart';
import '../features/profile/presentation/screens/profile_screen.dart';
import '../features/profile/public_profile/domain/public_profile_data.dart';
import '../features/profile/public_profile/screens/public_profile_screen.dart';
import '../features/rides/create/presentation/post_ride_screen.dart';
import '../features/offers/presentation/screens/offers_list_screen.dart';
import '../features/rides/presentation/screens/rides_home_screen.dart';
import '../features/seats/create/domain/seat_prefill.dart';
import '../features/seats/create/presentation/post_seat_screen.dart';
import 'auth_redirect.dart';
import 'error_screen.dart';
import 'routes.dart';
import 'splash_screen.dart';

part 'router_config.g.dart';

// Navigator key for root navigator (routes above tabs)
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter router(Ref ref) {
  final refreshListenable = RouterRefreshListenable(ref);

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
                builder: (context, state) => const RidesHomeScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.ridesList,
                    name: RouteNames.ridesList,
                    builder: (context, state) => const OffersListScreen(),
                  ),
                  GoRoute(
                    path: RoutePaths.seatsList,
                    name: RouteNames.seatsList,
                    builder: (context, state) => const OffersListScreen(),
                  ),
                  GoRoute(
                    path: RoutePaths.offerDetails,
                    name: RouteNames.offerDetails,
                    redirect: (context, state) {
                      final param = state.pathParameters['offerKey']!;
                      if (OfferKey.fromRouteParam(param) == null) {
                        return RoutePaths.rides;
                      }
                      return null;
                    },
                    builder: (context, state) {
                      final offerKey = OfferKey.fromRouteParam(
                        state.pathParameters['offerKey']!,
                      )!;
                      return OfferDetailsScreen(offerKey: offerKey);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 1: Packages
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.packages,
                name: RouteNames.packages,
                builder: (context, state) => const PackagesScreen(),
              ),
            ],
          ),

          // Branch 2: My Offers (center tab)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.myOffers,
                name: RouteNames.myOffers,
                builder: (context, state) => const MyOffersScreen(),
                routes: [
                  GoRoute(
                    path: RoutePaths.myOfferDetails,
                    name: RouteNames.myOfferDetails,
                    redirect: (context, state) {
                      final param = state.pathParameters['offerKey']!;
                      if (OfferKey.fromRouteParam(param) == null) {
                        return RoutePaths.myOffers;
                      }
                      return null;
                    },
                    builder: (context, state) {
                      final offerKey = OfferKey.fromRouteParam(
                        state.pathParameters['offerKey']!,
                      )!;
                      return OfferDetailsScreen(offerKey: offerKey);
                    },
                  ),
                ],
              ),
            ],
          ),

          // Branch 3: Profile
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

          // Branch 4: Messages
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
        parentNavigatorKey: _rootNavigatorKey,
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
        path: RoutePaths.publicProfile,
        name: RouteNames.publicProfile,
        parentNavigatorKey: _rootNavigatorKey,
        redirect: (context, state) {
          final idStr = state.pathParameters['userId'];
          if (idStr == null || int.tryParse(idStr) == null) {
            return RoutePaths.rides;
          }
          return null;
        },
        builder: (context, state) {
          final userId = int.parse(state.pathParameters['userId']!);
          final extra = state.extra;
          final profileData =
              extra is PublicProfileData ? extra : null;

          return PublicProfileScreen(
            userId: userId,
            initialData: profileData,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.postRide,
        name: RouteNames.postRide,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final prefillOrigin = state.extra as Location?;
          return PostRideScreen(prefillOrigin: prefillOrigin);
        },
      ),
      GoRoute(
        path: RoutePaths.postSeat,
        name: RouteNames.postSeat,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final prefill = state.extra as SeatPrefill?;
          return PostSeatScreen(
            prefillOrigin: prefill?.origin,
            prefillDestination: prefill?.destination,
            prefillDate: prefill?.date,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.verifyResult,
        name: RouteNames.verifyResult,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final status = state.uri.queryParameters['status'];
          return VerifyResultScreen(status: status);
        },
      ),
      GoRoute(
        path: RoutePaths.devGallery,
        name: RouteNames.devGallery,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ComponentGalleryScreen(),
      ),
    ],
  );

  // Dispose router when provider is disposed
  ref.onDispose(() {
    router.dispose();
  });

  return router;
}
