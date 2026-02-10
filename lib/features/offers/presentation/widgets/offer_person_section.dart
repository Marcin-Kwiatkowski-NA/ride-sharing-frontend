import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../routes/routes.dart';
import '../../domain/offer_models.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_details_strings.dart';

/// Driver/passenger section: user info card with optional source chip
/// and chat-bubble styled description.
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
            onTap: user.profileData != null
                ? () => context.pushNamed(
                      RouteNames.publicProfile,
                      pathParameters: {
                        'userId': user.profileData!.userId.toString(),
                      },
                      extra: user.profileData,
                    )
                : null,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Hero(
                    tag: 'avatar-${user.userId}',
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(
                        Icons.person,
                        size: 28,
                        color: cs.onPrimaryContainer,
                      ),
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
                                context.l10n.ratingDisplay(
                                  user.rating!.toStringAsFixed(1),
                                  user.completedTrips ?? 0,
                                ),
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                        if (isExternalSource) ...[
                          const SizedBox(height: 8),
                          _SourceChip(cs: cs, tt: tt),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ),
            ),
          ),
          // Description: chat-bubble style
          if (description != null && description!.isNotEmpty) ...[
            Divider(indent: 16, endIndent: 16, height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 20,
                      color: cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        description!,
                        style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SourceChip extends StatelessWidget {
  const _SourceChip({required this.cs, required this.tt});

  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: cs.tertiaryContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
        ),
      ),
      child: Text(
        context.l10n.sourceFacebook,
        style: tt.labelSmall?.copyWith(color: cs.onTertiaryContainer),
      ),
    );
  }
}
