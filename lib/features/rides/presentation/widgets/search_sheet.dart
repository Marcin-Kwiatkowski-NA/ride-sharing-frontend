import 'dart:ui';

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

/// Opens the search sheet as a modal bottom sheet with glassmorphism styling.
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
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
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

    ref.read(searchCriteriaProvider.notifier).commitDraft(_draft);

    final snapshot = RecentSearchSnapshot.fromDraft(_draft, mode);
    ref.read(recentSearchesProvider.notifier).addSearch(snapshot);

    Navigator.of(context).pop();

    if (mode == SearchMode.passengers) {
      context.goNamed(RouteNames.seatsList);
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final mode = ref.watch(searchModeProvider);
    final hasDate = _draft.departureDate != null;
    final hasBothCities = _draft.origin != null && _draft.destination != null;

    final searchLabel = mode == SearchMode.passengers
        ? 'Search Passengers'
        : 'Search Rides';

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: const Border(
              top: BorderSide(color: Colors.white12),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Mode toggle + close
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
                          icon: Icon(Icons.hail),
                        ),
                      ],
                      selected: {mode},
                      onSelectionChanged: (selected) {
                        ref
                            .read(searchModeProvider.notifier)
                            .setMode(selected.first);
                      },
                      style: ButtonStyle(
                        foregroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.onPrimary;
                          }
                          return Colors.white70;
                        }),
                        backgroundColor:
                            WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return colorScheme.primary;
                          }
                          return Colors.white.withValues(alpha: 0.1);
                        }),
                        side: WidgetStateProperty.all(
                          BorderSide(
                              color: Colors.white.withValues(alpha: 0.2)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Route section with timeline decoration
              _buildRouteSection(colorScheme, hasBothCities),

              const SizedBox(height: 16),

              // Date chip
              Align(
                alignment: Alignment.centerLeft,
                child: InputChip(
                  avatar: Icon(
                    Icons.calendar_today,
                    size: 18,
                    color: hasDate ? colorScheme.onPrimary : Colors.white70,
                  ),
                  label: Text(
                    hasDate
                        ? DateFormat('EEE, d MMM').format(_draft.departureDate!)
                        : 'Any date',
                  ),
                  selected: hasDate,
                  onPressed: _pickDate,
                  onDeleted: hasDate ? _clearDate : null,
                  selectedColor: colorScheme.primary,
                  backgroundColor: Colors.white.withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    color: hasDate ? colorScheme.onPrimary : Colors.white,
                  ),
                  side: BorderSide(
                    color: hasDate
                        ? Colors.transparent
                        : Colors.white.withValues(alpha: 0.2),
                  ),
                  deleteIconColor:
                      hasDate ? colorScheme.onPrimary : Colors.white54,
                ),
              ),

              const SizedBox(height: 28),

              // Footer actions
              FilledButton(
                onPressed: _onSearch,
                style: FilledButton.styleFrom(
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(searchLabel),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton.icon(
                  onPressed: _onClear,
                  icon: const Icon(Icons.clear_all, size: 18),
                  label: const Text('Clear All'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white54,
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteSection(ColorScheme colorScheme, bool hasBothCities) {
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
                  color: Colors.white.withValues(alpha: 0.2),
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
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: Icon(Icons.swap_vert, color: colorScheme.primary),
              onPressed: _swapCities,
              tooltip: 'Swap cities',
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
                  color: Colors.white.withValues(alpha: 0.2),
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
}
