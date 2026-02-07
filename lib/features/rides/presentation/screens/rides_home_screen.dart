import 'package:flutter/material.dart';

import '../../../../shared/widgets/background.dart';
import '../widgets/hero_search_card.dart';
import '../widgets/home_bottom_action_bar.dart';
import '../widgets/recent_searches_list.dart';

/// Intent-based launcher for the Rides tab.
///
/// Layout (top → bottom):
/// - Optically-centered search group: [HeroSearchCard] + [RecentSearchesList]
/// - Open background space
/// - Floating [HomeBottomActionBar] capsule near the bottom
class RidesHomeScreen extends StatelessWidget {
  const RidesHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Background(
      child: Stack(
        children: [
          // Gradient overlay for readability over the background image.
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: const [
                    Color(0xDD000000),
                    Color(0x80000000),
                    Color(0x80000000),
                    Color(0xDD000000),
                  ],
                  stops: const [0.0, 0.35, 0.65, 1.0],
                ),
              ),
            ),
          ),

          // Search group — slightly above optical center.
          Align(
            alignment: const Alignment(0, -0.2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    HeroSearchCard(),
                    SizedBox(height: 8),
                    RecentSearchesList(),
                  ],
                ),
              ),
            ),
          ),

          // Floating command capsule.
          Positioned(
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: const HomeBottomActionBar(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
