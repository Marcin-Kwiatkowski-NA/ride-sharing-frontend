import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../routes/routes.dart';
import '../providers/search_criteria_provider.dart';

/// Secondary CTA card to offer a ride, shown on the RidesHomeScreen.
class PostRideCta extends ConsumerWidget {
  const PostRideCta({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 1,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          final origin = ref.read(searchCriteriaProvider).origin;
          context.pushNamed(RouteNames.postRide, extra: origin);
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(
                Icons.directions_car_outlined,
                color: colorScheme.onSecondaryContainer,
                size: 28,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Offer a ride',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSecondaryContainer,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: colorScheme.onSecondaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
