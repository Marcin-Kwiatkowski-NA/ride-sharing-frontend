import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/providers/auth_notifier.dart';
import '../../routes/routes.dart';

/// Main layout with persistent bottom navigation.
/// Uses StatefulShellRoute to keep tab screens alive and preserve state.
class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  // Tab indices: 0=Rides, 1=Packages are public; 2=MyOffers, 3=Profile, 4=Messages require auth
  static const _protectedTabs = {2, 3, 4};

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          // Intercept protected tabs when not authenticated
          if (_protectedTabs.contains(index) && !isAuthenticated) {
            final currentLocation = GoRouterState.of(context).uri.toString();
            final destination = switch (index) {
              2 => '/my-offers',
              3 => '/profile',
              _ => '/messages',
            };
            context.pushNamed(
              RouteNames.login,
              queryParameters: {
                'from': destination,
                'back': currentLocation,
              },
            );
            return;
          }

          // goBranch switches tabs while preserving per-branch stacks
          // initialLocation: true when re-tapping current tab = pop to branch root
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.directions_car_outlined),
            selectedIcon: const Icon(Icons.directions_car),
            label: context.l10n.navRides,
          ),
          NavigationDestination(
            icon: const Icon(Icons.inventory_2_outlined),
            selectedIcon: const Icon(Icons.inventory_2),
            label: context.l10n.navPackages,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_offer_outlined),
            selectedIcon: const Icon(Icons.local_offer),
            label: context.l10n.navMyOffers,
          ),
          NavigationDestination(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            label: context.l10n.navProfile,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_outlined),
            selectedIcon: const Icon(Icons.chat),
            label: context.l10n.navMessages,
          ),
        ],
      ),
    );
  }
}
