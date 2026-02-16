import 'package:flutter/material.dart';

import '../../core/l10n/l10n_extension.dart';
import '../../core/theme/app_tokens.dart';
import '../../features/offers/domain/part_of_day.dart';
import '../../l10n/generated/app_localizations.dart';
import 'departure_picker_helpers.dart';

/// Minimalist "two big buttons" date + time selector.
///
/// A single outlined container holds two tappable tiles — Date and Time.
/// Pure presentation widget — delegates all state changes via callbacks.
class DepartureTimeSection extends StatelessWidget {
  final DateTime? selectedDate;
  final TimeOfDay? exactTime;
  final PartOfDay? selectedPartOfDay;
  final bool isApproximate;
  final VoidCallback onDateTap;
  final VoidCallback onTimeTap;
  final String? dateError;
  final String? timeError;

  const DepartureTimeSection({
    super.key,
    required this.selectedDate,
    this.exactTime,
    this.selectedPartOfDay,
    required this.isApproximate,
    required this.onDateTap,
    required this.onTimeTap,
    this.dateError,
    this.timeError,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final hasError = dateError != null || timeError != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Two-tile container
        Container(
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
            border: Border.all(
              color: hasError ? colorScheme.error : colorScheme.outlineVariant,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Date tile
                  Expanded(
                    child: _Tile(
                      label: l10n.dateLabel.toUpperCase(),
                      value: selectedDate != null
                          ? formatDateForTile(selectedDate!, locale: locale)
                          : null,
                      placeholder: l10n.selectDepartureDate,
                      icon: Icons.calendar_today_outlined,
                      isSet: selectedDate != null,
                      onTap: onDateTap,
                    ),
                  ),

                  // Vertical divider
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant,
                  ),

                  // Time tile
                  Expanded(
                    child: _Tile(
                      label: l10n.timeLabel.toUpperCase(),
                      value: _formatTimeValue(l10n),
                      placeholder: l10n.selectDepartureTime,
                      icon: Icons.access_time_outlined,
                      isSet: _hasTimeValue,
                      onTap: onTimeTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // Error messages
        if (dateError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 4),
            child: Text(
              dateError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
        if (timeError != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 4),
            child: Text(
              timeError!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.error,
              ),
            ),
          ),
      ],
    );
  }

  bool get _hasTimeValue =>
      (!isApproximate && exactTime != null) ||
      (isApproximate && selectedPartOfDay != null);

  String? _formatTimeValue(AppLocalizations l10n) {
    if (!isApproximate && exactTime != null) {
      return formatPickedTime(exactTime!);
    }
    if (isApproximate && selectedPartOfDay != null) {
      return _partOfDayLabel(selectedPartOfDay!, l10n);
    }
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single tile (Date or Time)
// ─────────────────────────────────────────────────────────────────────────────

class _Tile extends StatelessWidget {
  final String label;
  final String? value;
  final String placeholder;
  final IconData icon;
  final bool isSet;
  final VoidCallback onTap;

  const _Tile({
    required this.label,
    this.value,
    required this.placeholder,
    required this.icon,
    required this.isSet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: isSet
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value ?? placeholder,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: isSet
                    ? colorScheme.onSurface
                    : colorScheme.onSurfaceVariant,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

String _partOfDayLabel(PartOfDay pod, AppLocalizations l10n) => switch (pod) {
      PartOfDay.morning => l10n.partOfDayMorning,
      PartOfDay.afternoon => l10n.partOfDayAfternoon,
      PartOfDay.evening => l10n.partOfDayEvening,
      PartOfDay.night => l10n.partOfDayNight,
    };
