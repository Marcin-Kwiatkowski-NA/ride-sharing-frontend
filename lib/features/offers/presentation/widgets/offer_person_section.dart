import 'package:flutter/material.dart';

import '../../domain/offer_models.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';

/// Driver/passenger section: user info card with optional 2-line description.
class OfferPersonSection extends StatelessWidget {
  const OfferPersonSection({
    super.key,
    required this.user,
    required this.description,
    required this.offerKind,
    required this.isExternalSource,
  });

  final OfferUserUi user;
  final String? description;
  final OfferKind offerKind;
  final bool isExternalSource;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final strings = OfferDetailsStrings(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tappable person row
          InkWell(
            onTap: () {
              // Future: navigate to user profile
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: cs.primaryContainer,
                    child: Icon(
                      Icons.person,
                      size: 28,
                      color: cs.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.displayName,
                          style: tt.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.driverSubtitle(
                            offerKind,
                            isExternalSource: isExternalSource,
                          ),
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (user.showRating) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                size: 16,
                                color: cs.tertiary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${user.rating!.toStringAsFixed(1)} (${user.completedTrips} rides)',
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          // Description: 2-line truncation
          if (description != null && description!.isNotEmpty) ...[
            const Divider(indent: 16, endIndent: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                description!,
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
