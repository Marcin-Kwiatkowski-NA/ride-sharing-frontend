import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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

  // Tab indices: 0=Rides, 1=Passengers are public; 2=Profile, 3=Messages require auth
  static const _protectedTabs = {2, 3};

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
            final destination = index == 2 ? '/profile' : '/messages';
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
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Rides',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Passengers',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
        ],
      ),
      // FAB visible only on Rides tab
      floatingActionButton: navigationShell.currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => context.pushNamed(RouteNames.postRide),
              label: const Text('POST RIDE'),
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
