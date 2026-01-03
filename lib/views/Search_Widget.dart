import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../utils/constants.dart';
import 'CityAutocompleteField.dart';
import 'Date_Search_Field.dart';

class DateSearchField extends StatelessWidget {
  const DateSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'Date',
        filled: true,
        fillColor: Colors.white60,
        labelStyle: Theme.of(context).textTheme.titleMedium,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        suffixIcon: const Icon(Icons.calendar_today),
      ),
      onTap: () { /* Your date picker logic here */ },
      style: Theme.of(context).textTheme.titleLarge,
    );
  }
}
// --- End of Placeholder Widgets ---


class SearchWidget extends StatefulWidget {
  final String title;

  const SearchWidget({super.key, this.title = 'Where to?'});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  // Store the selected city IDs
  int? _originCityOsmId;
  int? _destinationCityOsmId;

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_originCityOsmId != null && _destinationCityOsmId != null) {
      // Handle the search logic
      print('Searching from City ID: $_originCityOsmId to City ID: $_destinationCityOsmId');
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Searching from ID:$_originCityOsmId to ID:$_destinationCityOsmId'))
      );
    } else {
      // This should not happen if the button is disabled correctly
      print('Origin or Destination not selected.');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if both fields have a selected city to enable the button
    final bool isSearchEnabled = _originCityOsmId != null && _destinationCityOsmId != null;

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue.shade50,
      child: Padding(
        padding: Constants().padding_20,
        child: Column(
          mainAxisSize: MainAxisSize.min, // Constrain column to its children's size
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

            // Use the new Autocomplete Widget for 'From'
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
            const SizedBox(height: 16), // Proper spacing

            // Use the new Autocomplete Widget for 'To'
            CityAutocompleteField(
              controller: _toController,
              labelText: 'To',
              prefixIcon: Icons.trip_origin,
              onCitySelected: (city) {
                setState(() {
                  _toController.text = city.name;
                  _destinationCityOsmId = city.osmId;
                });
              },
            ),
            const SizedBox(height: 16), // Proper spacing

            const DateSearchField(),
            const SizedBox(height: 24), // Proper spacing

            ElevatedButton(
              onPressed: isSearchEnabled ? _performSearch : null, // Enable button conditionally
              style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)
                  )
              ),
              child: const Text('Search'),
            ),
          ],
        ),
      ),
    );
  }
}