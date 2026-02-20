import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/providers/auth_notifier.dart';
import '../../core/theme/layout_tokens.dart';
import '../../routes/routes.dart';

/// Single destination model — generates both NavigationDestination and
/// NavigationRailDestination from one definition so labels/icons never drift.
class _NavItem {
  final Icon icon;
  final Icon selectedIcon;
  final String Function(BuildContext) label;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  NavigationDestination toBarDestination(BuildContext context) =>
      NavigationDestination(
        icon: icon,
        selectedIcon: selectedIcon,
        label: label(context),
      );

  NavigationRailDestination toRailDestination(BuildContext context) =>
      NavigationRailDestination(
        icon: icon,
        selectedIcon: selectedIcon,
        label: Text(label(context)),
      );
}

/// Main layout with adaptive navigation.
///
/// - compact + medium (< 840): Bottom NavigationBar (mobile-first)
/// - expanded (840-1199): Collapsed NavigationRail with selected labels
/// - large+ (>= 1200): Extended NavigationRail (labels always shown)
///
/// Uses [WindowWidthClass.of(context)] (viewport-level) since this is
/// the outermost layout shell.
class MainLayout extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const MainLayout({
    super.key,
    required this.navigationShell,
  });

  // Tab indices: 0=Rides, 1=Packages are public; 2=MyOffers, 3=Profile, 4=Messages require auth
  static const _protectedTabs = {2, 3, 4};

  static final _destinations = [
    _NavItem(
      icon: const Icon(Icons.directions_car_outlined),
      selectedIcon: const Icon(Icons.directions_car),
      label: (c) => c.l10n.navRides,
    ),
    _NavItem(
      icon: const Icon(Icons.inventory_2_outlined),
      selectedIcon: const Icon(Icons.inventory_2),
      label: (c) => c.l10n.navPackages,
    ),
    _NavItem(
      icon: const Icon(Icons.list_alt_outlined),
      selectedIcon: const Icon(Icons.list_alt),
      label: (c) => c.l10n.navMyActivity,
    ),
    _NavItem(
      icon: const Icon(Icons.person_outline),
      selectedIcon: const Icon(Icons.person),
      label: (c) => c.l10n.navProfile,
    ),
    _NavItem(
      icon: const Icon(Icons.chat_outlined),
      selectedIcon: const Icon(Icons.chat),
      label: (c) => c.l10n.navMessages,
    ),
  ];

  void _onDestinationSelected({
    required BuildContext context,
    required bool isAuthenticated,
    required int index,
  }) {
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
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;
    final sizeClass = WindowWidthClass.of(context);
    final useRail = sizeClass >= WindowWidthClass.expanded;
    final extendRail = sizeClass >= WindowWidthClass.large;

    return Scaffold(
      body: useRail
          ? Row(
              children: [
                SafeArea(
                  child: NavigationRail(
                    selectedIndex: navigationShell.currentIndex,
                    onDestinationSelected: (i) => _onDestinationSelected(
                      context: context,
                      isAuthenticated: isAuthenticated,
                      index: i,
                    ),
                    destinations: _destinations
                        .map((d) => d.toRailDestination(context))
                        .toList(),
                    extended: extendRail,
                    labelType: extendRail
                        ? NavigationRailLabelType.none
                        : NavigationRailLabelType.selected,
                  ),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: navigationShell),
              ],
            )
          : navigationShell,
      bottomNavigationBar: useRail
          ? null
          : NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (i) => _onDestinationSelected(
                context: context,
                isAuthenticated: isAuthenticated,
                index: i,
              ),
              destinations: _destinations
                  .map((d) => d.toBarDestination(context))
                  .toList(),
            ),
    );
  }
}
