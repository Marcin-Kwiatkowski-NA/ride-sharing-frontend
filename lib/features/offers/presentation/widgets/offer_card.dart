import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/offer_ui_model.dart';
import '../helpers/offer_l10n.dart';

/// Horizontal offer card with Time | Route+Driver | Price layout.
///
/// ```
/// ┌──────────────────────────────────────────────────┐
/// │  Morning    │  Łódź          ○ Jan │      35 zł  │
/// │  Flexible   │  ↓                   │     2 seats  │
/// │             │  Kraków              │              │
/// └──────────────────────────────────────────────────┘
/// ```
class OfferCard extends StatelessWidget {
  final OfferUiModel offer;
  final VoidCallback? onTap;

  const OfferCard({super.key, required this.offer, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppTokens.elevationLow,
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Left: Time anchor
              SizedBox(
                width: 80,
                child: _TimeAnchor(offer: offer),
              ),
              // Vertical divider
              _verticalDivider(context),
              // Middle: Route + Driver
              Expanded(
                child: _RouteSection(offer: offer),
              ),
              const SizedBox(width: 12),
              // Right: Price + Seats
              _PriceSection(offer: offer),
            ],
          ),
        ),
      ),
    );
  }

  Widget _verticalDivider(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        height: 48,
        child: VerticalDivider(
          width: 1,
          thickness: 1,
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Left section: time anchor for quick scanning.
class _TimeAnchor extends StatelessWidget {
  final OfferUiModel offer;

  const _TimeAnchor({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    // Undefined time
    if (offer.isTimeUndefined) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.anyTime,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    }

    // Exact time (not approximate)
    if (offer.exactTimeDisplay != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            offer.exactTimeDisplay!,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            offer.localizedPartOfDay(l10n),
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    // Approximate (flexible)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          offer.localizedPartOfDay(l10n),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: ShapeDecoration(
            color: colorScheme.tertiaryContainer,
            shape: const StadiumBorder(),
          ),
          child: Text(
            l10n.flexible,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onTertiaryContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Middle section: route (origin → destination).
class _RouteSection extends StatelessWidget {
  final OfferUiModel offer;

  const _RouteSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          offer.originName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Icon(
            Icons.arrow_downward,
            size: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          offer.destinationName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Right section: price and seat count.
class _PriceSection extends StatelessWidget {
  final OfferUiModel offer;

  const _PriceSection({required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (offer.hasMoneyAmount)
          Text(
            offer.localizedMoneyValue(l10n),
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.primary,
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: ShapeDecoration(
              color: colorScheme.tertiaryContainer,
              shape: const StadiumBorder(),
            ),
            child: Text(
              offer.localizedMoneyValue(l10n),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onTertiaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                offer.countIcon,
                size: 14,
                color: colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 3),
              Text(
                offer.localizedCountDisplay(l10n),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
