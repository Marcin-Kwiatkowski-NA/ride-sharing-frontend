import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:blablafront/core/widgets/core_widgets.dart';

import '../../../../utils/constants.dart';
import '../../../../shared/widgets/city_autocomplete_field.dart';
import '../../../../shared/widgets/date_search_field.dart';
import '../../../../shared/widgets/time_search_field.dart';
import '../providers/search_criteria_provider.dart';
import '../screens/rides_list_screen.dart';

class SearchWidget extends ConsumerStatefulWidget {
  final String title;

  const SearchWidget({super.key, this.title = 'Where to?'});

  @override
  ConsumerState<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends ConsumerState<SearchWidget> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _anyTime = true;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
      _anyTime = true;
      _selectedTime = null;
    });
  }

  void _onTimeSelected(TimeOfDay? time) {
    setState(() {
      _selectedTime = time;
      _anyTime = false;
    });
  }

  void _selectAnyTime() {
    setState(() {
      _anyTime = true;
      _selectedTime = null;
    });
  }

  void _performSearch() {
    // Update search criteria via Riverpod
    final notifier = ref.read(searchCriteriaProvider.notifier);
    notifier.clear();

    final origin = _fromController.text.trim();
    final destination = _toController.text.trim();

    if (origin.isNotEmpty) {
      notifier.setOrigin(origin);
    }
    if (destination.isNotEmpty) {
      notifier.setDestination(destination);
    }
    if (_selectedDate != null) {
      notifier.setDepartureDate(_selectedDate);
    }
    if (!_anyTime && _selectedTime != null) {
      notifier.setDepartureTime(_selectedTime);
    }

    // Navigate to rides list screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RidesListScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: theme.colorScheme.primaryContainer,
      child: Padding(
        padding: Constants().padding_20,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: Text(
                  widget.title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.abel(
                      fontSize: 40, color: theme.colorScheme.primary),
                ),
              ),

            CityAutocompleteField(
              controller: _fromController,
              labelText: 'From',
              prefixIcon: Icons.trip_origin,
              onCitySelected: (city) {
                setState(() {
                  _fromController.text = city.name;
                });
              },
              onCityCleared: () {},
            ),
            const SizedBox(height: 16),

            CityAutocompleteField(
              controller: _toController,
              labelText: 'To',
              prefixIcon: Icons.location_on,
              onCitySelected: (city) {
                setState(() {
                  _toController.text = city.name;
                });
              },
              onCityCleared: () {},
            ),
            const SizedBox(height: 16),

            DateSearchField(onDateSelected: _onDateSelected),

            if (_selectedDate != null) ...[
              const SizedBox(height: 16),
              _buildTimeSection(context),
            ],

            const SizedBox(height: 24),

            PrimaryButton(
              onPressed: _performSearch,
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSection(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _selectAnyTime,
            icon: Icon(
              _anyTime ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
            ),
            label: const Text('Any time'),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  _anyTime ? theme.colorScheme.primary : Colors.grey.shade300,
              foregroundColor: _anyTime ? Colors.white : Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TimeSearchField(
            onTimeSelected: _onTimeSelected,
            initialTime: _selectedTime,
          ),
        ),
      ],
    );
  }
}
