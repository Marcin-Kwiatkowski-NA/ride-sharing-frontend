import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../shared/widgets/location_picker_dialog.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../routes/routes.dart';
import '../../data/dto/draft_search_criteria.dart';
import '../../data/dto/recent_search_snapshot.dart';
import '../providers/paginated_rides_provider.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_criteria_provider.dart';
import '../providers/search_mode_provider.dart';
import '../../../seats/presentation/providers/paginated_seats_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public entry point
// ─────────────────────────────────────────────────────────────────────────────

/// Opens the search sheet as a modal bottom sheet with glassmorphism styling.
void showSearchSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _SearchSheetWrapper(),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Sheet wrapper (DraggableScrollableSheet)
// ─────────────────────────────────────────────────────────────────────────────

class _SearchSheetWrapper extends StatelessWidget {
  const _SearchSheetWrapper();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return _SearchSheetContent(scrollController: scrollController);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Main sheet content (stateful, Riverpod)
// ─────────────────────────────────────────────────────────────────────────────

class _SearchSheetContent extends ConsumerStatefulWidget {
  final ScrollController scrollController;

  const _SearchSheetContent({required this.scrollController});

  @override
  ConsumerState<_SearchSheetContent> createState() =>
      _SearchSheetContentState();
}

class _SearchSheetContentState extends ConsumerState<_SearchSheetContent> {
  DraftSearchCriteria _draft = const DraftSearchCriteria();
  late final TextEditingController _fromController;
  late final TextEditingController _toController;

  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _fromController = TextEditingController();
    _toController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_hydrated) return;

    final committed = ref.read(searchCriteriaProvider);
    _draft = DraftSearchCriteria.fromCommitted(committed);

    _fromController.text = _draft.origin?.name ?? '';
    _toController.text = _draft.destination?.name ?? '';

    _hydrated = true;
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  // ── Actions ──────────────────────────────────────────────────────────────

  void _onSearch() {
    final mode = ref.read(searchModeProvider);

    ref.read(searchCriteriaProvider.notifier).commitDraft(_draft);

    // Force fresh fetch even when criteria haven't changed.
    ref.invalidate(paginatedRidesProvider);
    ref.invalidate(paginatedSeatsProvider);

    final snapshot = RecentSearchSnapshot.fromDraft(_draft, mode);
    ref.read(recentSearchesProvider.notifier).addSearch(snapshot);

    Navigator.of(context).pop();

    // Always navigate to the unified list screen — mode is handled inline.
    context.goNamed(RouteNames.ridesList);
  }

  void _onClear() {
    setState(() {
      _draft = const DraftSearchCriteria();
      _fromController.clear();
      _toController.clear();
    });
  }

  void _swapCities() {
    setState(() {
      _draft = _draft.copyWith(
        origin: _draft.destination,
        destination: _draft.origin,
      );
      _fromController.text = _draft.origin?.name ?? '';
      _toController.text = _draft.destination?.name ?? '';
    });
  }

  Future<void> _pickLocation({required bool isOrigin}) async {
    final location = await showLocationPickerDialog(
      context,
      title: isOrigin ? context.l10n.fromLabel : context.l10n.toLabel,
    );

    if (!mounted || location == null) return;

    setState(() {
      if (isOrigin) {
        _draft = _draft.copyWith(origin: location);
        _fromController.text = location.name;
      } else {
        _draft = _draft.copyWith(destination: location);
        _toController.text = location.name;
      }
    });
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _draft.departureDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null && mounted) {
      setState(() {
        _draft = _draft.copyWith(departureDate: normalizeDate(date));
      });
    }
  }

  void _clearDate() {
    setState(() {
      _draft = _draft.copyWith(
        departureDate: null,
        departureTime: null,
        anyTime: true,
      );
    });
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final tokens = Theme.of(context).extension<AppTokens>()!;
    final mode = ref.watch(searchModeProvider);
    final hasDate = _draft.departureDate != null;
    final hasBothCities = _draft.origin != null && _draft.destination != null;

    final l10n = context.l10n;
    final searchLabel = mode == SearchMode.passengers
        ? l10n.searchPassengers
        : l10n.searchRides;

    final colorScheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTokens.radiusXL),
        ),
        border: Border(
          top: BorderSide(color: tokens.overlayBorder),
        ),
        boxShadow: [
          BoxShadow(
            color: tokens.overlayScrim,
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: tokens.overlayDragHandle,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Mode toggle + close
          Row(
            children: [
              Expanded(
                child: SegmentedButton<SearchMode>(
                  segments: [
                    ButtonSegment(
                      value: SearchMode.rides,
                      label: Text(l10n.navRides),
                      icon: const Icon(Icons.directions_car_outlined),
                    ),
                    ButtonSegment(
                      value: SearchMode.passengers,
                      label: Text(l10n.passengers),
                      icon: const Icon(Icons.hail),
                    ),
                  ],
                  selected: {mode},
                  onSelectionChanged: (selected) {
                    ref
                        .read(searchModeProvider.notifier)
                        .setMode(selected.first);
                  },
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Route picker card
          _RoutePickerCard(
            originName: _draft.origin?.name,
            destinationName: _draft.destination?.name,
            showSwap: hasBothCities,
            onFromTap: () => _pickLocation(isOrigin: true),
            onToTap: () => _pickLocation(isOrigin: false),
            onSwap: _swapCities,
          ),

          const SizedBox(height: 12),

          // Date tile
          _buildDateTile(theme, colorScheme, hasDate),

          const SizedBox(height: 28),

          // Footer actions
          FilledButton(
            onPressed: _onSearch,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(52),
            ),
            child: Text(searchLabel),
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: _onClear,
              icon: const Icon(Icons.clear_all, size: 18),
              label: Text(l10n.clearAll),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildDateTile(
    ThemeData theme,
    ColorScheme colorScheme,
    bool hasDate,
  ) {
    final l10n = context.l10n;
    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      elevation: AppTokens.elevationLow,
      child: InkWell(
        onTap: _pickDate,
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 22,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dateLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDate
                          ? DateFormat('EEE, d MMM yyyy')
                              .format(_draft.departureDate!)
                          : l10n.anyDate,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: hasDate
                            ? colorScheme.onSurface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasDate)
                IconButton(
                  icon:
                      Icon(Icons.close, size: 18, color: colorScheme.outline),
                  onPressed: _clearDate,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  tooltip: l10n.clearDate,
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Picker Card
// ─────────────────────────────────────────────────────────────────────────────

class _RoutePickerCard extends StatelessWidget {
  final String? originName;
  final String? destinationName;
  final bool showSwap;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  final VoidCallback onSwap;

  const _RoutePickerCard({
    required this.originName,
    required this.destinationName,
    required this.showSwap,
    required this.onFromTap,
    required this.onToTap,
    required this.onSwap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      elevation: AppTokens.elevationLow,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _RouteRow(
                icon: Icons.trip_origin,
                label: 'From',
                value: originName,
                onTap: onFromTap,
              ),
              const Divider(height: 1, indent: 52),
              _RouteRow(
                icon: Icons.location_on,
                label: 'To',
                value: destinationName,
                onTap: onToTap,
              ),
            ],
          ),

          // Swap button overlay
          if (showSwap)
            Positioned(
              right: 8,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.swap_vert, color: colorScheme.primary),
                    onPressed: onSwap,
                    tooltip: context.l10n.swapOriginDestination,
                    iconSize: 20,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Route Row (single tappable row inside the card)
// ─────────────────────────────────────────────────────────────────────────────

class _RouteRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  const _RouteRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasValue = value != null && value!.isNotEmpty;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: colorScheme.primary),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasValue ? value! : context.l10n.chooseCity,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: hasValue
                          ? colorScheme.onSurface
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ],
        ),
      ),
    );
  }
}

