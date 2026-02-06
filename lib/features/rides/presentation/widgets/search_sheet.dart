import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/cities/widgets/city_autocomplete_field.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../routes/routes.dart';
import '../../data/dto/draft_search_criteria.dart';
import '../../data/dto/recent_search_snapshot.dart';
import '../providers/recent_searches_provider.dart';
import '../providers/search_criteria_provider.dart';
import '../providers/search_mode_provider.dart';

/// Opens the search sheet as a modal bottom sheet.
void showSearchSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _SearchSheetWrapper(),
  );
}

class _SearchSheetWrapper extends StatelessWidget {
  const _SearchSheetWrapper();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return _SearchSheetContent(scrollController: scrollController);
      },
    );
  }
}

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

  void _onSearch() {
    final mode = ref.read(searchModeProvider);

    // Commit draft to the shared search criteria
    ref.read(searchCriteriaProvider.notifier).commitDraft(_draft);

    // Save to recent searches
    final snapshot = RecentSearchSnapshot.fromDraft(_draft, mode);
    ref.read(recentSearchesProvider.notifier).addSearch(snapshot);

    // Close sheet
    Navigator.of(context).pop();

    // Navigate based on mode
    if (mode == SearchMode.passengers) {
      context.goNamed(RouteNames.passengersListPlaceholder);
    } else {
      context.goNamed(RouteNames.ridesList);
    }
  }

  void _onClear() {
    setState(() {
      _draft = const DraftSearchCriteria();
      _fromController.clear();
      _toController.clear();
    });
  }

  void _onRecentTap(RecentSearchSnapshot recent) {
    setState(() {
      _draft = DraftSearchCriteria.fromSnapshot(recent);
      _fromController.text = _draft.origin?.name ?? '';
      _toController.text = _draft.destination?.name ?? '';
    });
    // Also set the mode to match the recent search
    ref.read(searchModeProvider.notifier).setMode(recent.mode);
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

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _draft.departureTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) {
      setState(() {
        _draft = _draft.copyWith(departureTime: time, anyTime: false);
      });
    }
  }

  void _selectAnyTime() {
    setState(() {
      _draft = _draft.copyWith(departureTime: null, anyTime: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mode = ref.watch(searchModeProvider);
    final recentsAsync = ref.watch(recentSearchesProvider);

    return Material(
      color: colorScheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header: SegmentedButton + close
          Row(
            children: [
              Expanded(
                child: SegmentedButton<SearchMode>(
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
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Route section with timeline decoration
          _buildRouteSection(theme, colorScheme),

          const SizedBox(height: 16),

          // Date field
          _buildDateField(theme, colorScheme),

          // Time row (only when date is set)
          if (_draft.departureDate != null) ...[
            const SizedBox(height: 12),
            _buildTimeRow(theme, colorScheme),
          ],

          const SizedBox(height: 20),

          // Recent searches
          _buildRecentSearches(theme, colorScheme, recentsAsync),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: _onSearch,
                  child: const Text('Search'),
                ),
              ),
              const SizedBox(width: 12),
              TextButton(
                onPressed: _onClear,
                child: const Text('Clear'),
              ),
            ],
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRouteSection(ThemeData theme, ColorScheme colorScheme) {
    final hasBothCities = _draft.origin != null && _draft.destination != null;

    return Column(
      children: [
        // From field with timeline dot
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                ),
                Container(
                  width: 2,
                  height: 24,
                  color: colorScheme.outlineVariant,
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CityAutocompleteField(
                controller: _fromController,
                labelText: 'From',
                prefixIcon: Icons.trip_origin,
                onCitySelected: (city) {
                  setState(() {
                    _draft = _draft.copyWith(origin: city);
                    _fromController.text = city.name;
                  });
                },
                onCityCleared: () {
                  setState(() {
                    _draft = _draft.copyWith(origin: null);
                  });
                },
              ),
            ),
          ],
        ),

        // Swap button
        if (hasBothCities)
          Padding(
            padding: const EdgeInsets.only(left: 0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: Icon(
                  Icons.swap_vert,
                  color: colorScheme.primary,
                ),
                onPressed: _swapCities,
                tooltip: 'Swap cities',
              ),
            ),
          ),

        // To field with timeline dot
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  width: 2,
                  height: hasBothCities ? 0 : 24,
                  color: colorScheme.outlineVariant,
                ),
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: colorScheme.primary,
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CityAutocompleteField(
                controller: _toController,
                labelText: 'To',
                prefixIcon: Icons.location_on,
                onCitySelected: (city) {
                  setState(() {
                    _draft = _draft.copyWith(destination: city);
                    _toController.text = city.name;
                  });
                },
                onCityCleared: () {
                  setState(() {
                    _draft = _draft.copyWith(destination: null);
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateField(ThemeData theme, ColorScheme colorScheme) {
    final hasDate = _draft.departureDate != null;

    return InkWell(
      onTap: _pickDate,
      borderRadius: BorderRadius.circular(12),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Date',
          prefixIcon: Icon(Icons.calendar_today, color: colorScheme.primary),
          suffixIcon: hasDate
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearDate,
                )
              : const Icon(Icons.arrow_drop_down),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(
          hasDate
              ? DateFormat('EEE, d MMM yyyy').format(_draft.departureDate!)
              : 'Any date',
          style: theme.textTheme.bodyLarge,
        ),
      ),
    );
  }

  Widget _buildTimeRow(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        FilterChip(
          label: const Text('Any time'),
          selected: _draft.anyTime,
          onSelected: (_) => _selectAnyTime(),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            borderRadius: BorderRadius.circular(12),
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Time',
                prefixIcon:
                    Icon(Icons.access_time, color: colorScheme.primary),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _draft.departureTime != null
                    ? _draft.departureTime!.format(context)
                    : 'Select time',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _draft.departureTime != null
                      ? colorScheme.onSurface
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentSearches(
    ThemeData theme,
    ColorScheme colorScheme,
    AsyncValue<List<RecentSearchSnapshot>> recentsAsync,
  ) {
    return recentsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (recents) {
        if (recents.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent searches',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: recents.map((recent) {
                return ActionChip(
                  avatar: Icon(
                    recent.mode == SearchMode.passengers
                        ? Icons.people_outline
                        : Icons.directions_car_outlined,
                    size: 18,
                  ),
                  label: Text(_recentLabel(recent)),
                  onPressed: () => _onRecentTap(recent),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }

  String _recentLabel(RecentSearchSnapshot recent) {
    final parts = <String>[];
    if (recent.origin != null && recent.destination != null) {
      parts.add('${recent.origin!.name} → ${recent.destination!.name}');
    } else if (recent.origin != null) {
      parts.add('From ${recent.origin!.name}');
    } else if (recent.destination != null) {
      parts.add('To ${recent.destination!.name}');
    }

    if (recent.departureDate != null) {
      parts.add(DateFormat('d MMM').format(recent.departureDate!));
    }

    return parts.isEmpty ? 'All rides' : parts.join(' · ');
  }
}
