import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';
import 'CityAutocompleteField.dart';
import 'Date_Search_Field.dart';
import 'search_results_screen.dart';

class SearchWidget extends StatefulWidget {
  final String title;

  const SearchWidget({super.key, this.title = 'Where to?'});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();
  DateTime? _selectedDate;

  // Store the selected city IDs
  int? _originCityOsmId;
  int? _destinationCityOsmId;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  void _performSearch() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsScreen(
          origin: _fromController.text.trim(),
          destination: _toController.text.trim(),
          departureDate: _selectedDate,
        ),
      ),
    );
  }

  bool get _canSearch {
    return _originCityOsmId != null && _destinationCityOsmId != null;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade50,
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
                  style: GoogleFonts.abel(fontSize: 40, color: Colors.blue.shade800),
                ),
              ),

            // Autocomplete Widget for 'From'
            CityAutocompleteField(
              controller: _fromController,
              labelText: 'From',
              prefixIcon: Icons.trip_origin,
              onCitySelected: (city) {
                setState(() {
                  _fromController.text = city.name;
                  _originCityOsmId = city.osmId;
                });
              },
            ),
            const SizedBox(height: 16),

            // Autocomplete Widget for 'To'
            CityAutocompleteField(
              controller: _toController,
              labelText: 'To',
              prefixIcon: Icons.location_on,
              onCitySelected: (city) {
                setState(() {
                  _toController.text = city.name;
                  _destinationCityOsmId = city.osmId;
                });
              },
            ),
            const SizedBox(height: 16),

            DateSearchField(onDateSelected: _onDateSelected),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _canSearch ? _performSearch : null,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}
