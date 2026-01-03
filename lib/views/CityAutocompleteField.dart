import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/City.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final void Function(City) onCitySelected;
  final String? Function(String?)? validator;


  const CityAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.onCitySelected,
    this.validator,
  });

  @override
  State<CityAutocompleteField> createState() => _CityAutocompleteFieldState();
}

class _CityAutocompleteFieldState extends State<CityAutocompleteField> {
  Timer? _debounce;
  List<City> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Static cache to persist across instances
  static final Map<String, List<City>> _cache = {};
  static const int _maxCacheSize = 50;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.length < 2) {
      setState(() { _suggestions = []; _isLoading = false; _errorMessage = null; });
      return;
    }

    // Check cache first
    final cacheKey = query.toLowerCase();
    if (_cache.containsKey(cacheKey)) {
      setState(() {
        _suggestions = _cache[cacheKey]!;
        _isLoading = false;
        _errorMessage = null;
      });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    final uri = Uri.parse('http://cggwocwcgkog4wow84k8goc8.130.61.31.172.sslip.io/api?q=$query&osm_tag=place:city&osm_tag=place:town&osm_tag=place:village');

    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 5));
      if (mounted && response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        final cities = (data['features'] as List).map((f) => City.fromJson(f)).toList();

        // Cache results (limit cache size)
        if (_cache.length >= _maxCacheSize) {
          _cache.remove(_cache.keys.first);
        }
        _cache[cacheKey] = cities;

        setState(() { _suggestions = cities; });
      } else {
        if (mounted) setState(() { _errorMessage = 'Failed to load cities'; _suggestions = []; });
      }
    } catch (e) {
      if (mounted) setState(() { _suggestions = []; _errorMessage = 'Connection error. Check your network.'; });
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Autocomplete<City>(
        optionsBuilder: (TextEditingValue textEditingValue) {
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            _fetchSuggestions(textEditingValue.text);
          });
          // Return current suggestions - loading/error handled in optionsViewBuilder
          return _suggestions;
        },
        displayStringForOption: (City option) => option.name,
        onSelected: (City selection) {
          widget.onCitySelected(selection);
          FocusScope.of(context).unfocus();
        },
        fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
          return TextFormField(
            controller: fieldController,
            focusNode: focusNode,
            validator: widget.validator,
            decoration: InputDecoration(
              labelText: widget.labelText,
              labelStyle: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant.withOpacity(0.8)),
              prefixIcon: Icon(widget.prefixIcon, color: theme.colorScheme.primary, size: 22),
              filled: true,
              fillColor: Colors.white.withOpacity(0.85),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.4))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0)),
            ),
            style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.onSurface),
          );
        },
        optionsViewBuilder: (context, onSelected, options) {
          // Determine what to show based on state
          Widget content;
          if (_isLoading) {
            content = const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          } else if (_errorMessage != null) {
            content = Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            );
          } else if (options.isEmpty) {
            content = const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No cities found'),
            );
          } else {
            content = ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: options.length,
              itemBuilder: (context, index) {
                final option = options.elementAt(index);
                return ListTile(
                  title: Text(option.name),
                  onTap: () => onSelected(option),
                );
              },
            );
          }

          return Align(
            alignment: Alignment.topLeft,
            child: Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(10.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 220),
                child: content,
              ),
            ),
          );
        }
    );
  }
}