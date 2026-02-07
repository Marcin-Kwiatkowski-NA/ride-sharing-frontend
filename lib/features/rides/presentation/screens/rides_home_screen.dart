import 'package:flutter/material.dart';

import '../../../../shared/widgets/background.dart';
import '../widgets/driver_conversion_tile.dart';
import '../widgets/hero_search_card.dart';

/// Intent-based launcher for the Rides tab.
///
/// Shows a centered hero search surface (passenger intent) and a floating
/// bottom driver conversion tile (driver intent).
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

          // Hero search card — centered.
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 500),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: HeroSearchCard(),
              ),
            ),
          ),

          // Driver conversion tile — bottom, above nav bar.
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: const DriverConversionTile(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
