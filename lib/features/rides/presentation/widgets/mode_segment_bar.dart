import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../seats/presentation/providers/paginated_seats_provider.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/search_mode_provider.dart';

/// M3 SegmentedButton for switching between Rides and Requests views.
///
/// Shows live counts from the paginated providers (e.g., "Rides · 24").
class ModeSegmentBar extends ConsumerWidget {
  const ModeSegmentBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(searchModeProvider);
    final ridesState = ref.watch(paginatedRidesProvider);
    final seatsState = ref.watch(paginatedSeatsProvider);

    final ridesLabel = _labelWithCount(context.l10n.filterRides, ridesState.totalElements, ridesState.isLoading);
    final requestsLabel = _labelWithCount(context.l10n.filterPassengers, seatsState.totalElements, seatsState.isLoading);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<SearchMode>(
          segments: [
            ButtonSegment(
              value: SearchMode.rides,
              label: Text(ridesLabel),
              icon: const Icon(Icons.directions_car_outlined),
            ),
            ButtonSegment(
              value: SearchMode.passengers,
              label: Text(requestsLabel),
              icon: const Icon(Icons.hail),
            ),
          ],
          selected: {mode},
          onSelectionChanged: (selected) {
            ref.read(searchModeProvider.notifier).setMode(selected.first);
          },
        ),
      ),
    );
  }

  String _labelWithCount(String label, int total, bool isLoading) {
    if (isLoading || total == 0) return label;
    return '$label \u00b7 $total';
  }
}
