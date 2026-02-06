import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/background.dart';
import '../providers/search_mode_provider.dart';
import '../widgets/post_ride_cta.dart';
import '../widgets/search_capsule.dart';

/// Hero home screen for the Rides tab.
/// Replaces the old SearchRideScreen as Branch 0 root.
class RidesHomeScreen extends ConsumerWidget {
  const RidesHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(searchModeProvider);

    return SafeArea(
      child: Background(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 48),

                  // Mode toggle
                  SegmentedButton<SearchMode>(
                    segments: const [
                      ButtonSegment(
                        value: SearchMode.rides,
                        label: Text('Rides'),
                        icon: Icon(Icons.directions_car_outlined),
                      ),
                      ButtonSegment(
                        value: SearchMode.passengers,
                        label: Text('Passengers'),
                        icon: Icon(Icons.people_outline),
                      ),
                    ],
                    selected: {mode},
                    onSelectionChanged: (selected) {
                      ref
                          .read(searchModeProvider.notifier)
                          .setMode(selected.first);
                    },
                  ),

                  const SizedBox(height: 16),

                  // Search capsule
                  const SearchCapsule(),

                  const SizedBox(height: 16),

                  // Post ride CTA
                  const PostRideCta(),

                  const Spacer(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
