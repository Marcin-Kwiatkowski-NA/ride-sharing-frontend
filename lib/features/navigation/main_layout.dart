import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/navigation_provider.dart';
import '../chat/presentation/tabs/messages_tab.dart';
import '../rides/presentation/screens/search_ride_screen.dart';
import '../passengers/presentation/screens/search_passenger_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../../routes/app_router.dart';

/// Main layout with persistent bottom navigation
/// Uses IndexedStack to keep tab screens alive and preserve state
class MainLayout extends ConsumerWidget {
  const MainLayout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          SearchRideScreen(),
          SearchPassengerScreen(),
          ProfileScreen(),
          MessagesTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
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
      // FAB visible only on Rides tab (index 0)
      floatingActionButton: currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () {
                AppRouter.navigateTo(context, AppRoutes.postRide);
              },
              label: const Text('POST RIDE'),
              icon: const Icon(Icons.add_circle_outline_rounded),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
