import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/City.dart';

class CityAutocompleteField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final void Function(City) onCitySelected;
  final void Function()? onCityCleared;
  final String? Function(String?)? validator;


  const CityAutocompleteField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    required this.onCitySelected,
    this.onCityCleared,
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

  // Recent cities selected by user (shared across all instances, persisted)
  static final List<City> _recentCities = [];
  static const int _maxRecentCities = 10;
  static const String _recentCitiesKey = 'recent_cities';
  static bool _recentCitiesLoaded = false;


  @override
  void initState() {
    super.initState();
    _loadRecentCities();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadRecentCities() async {
    if (_recentCitiesLoaded) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_recentCitiesKey);
      if (jsonString != null) {
        final List<dynamic> jsonList = json.decode(jsonString);
        _recentCities.clear();
        _recentCities.addAll(jsonList.map((j) => City.fromStorageJson(j)).toList());
      }
      _recentCitiesLoaded = true;
      if (mounted) setState(() {});
    } catch (e) {
      // Ignore errors loading recent cities
    }
  }

  Future<void> _saveRecentCities() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = _recentCities.map((c) => c.toStorageJson()).toList();
      await prefs.setString(_recentCitiesKey, json.encode(jsonList));
    } catch (e) {
      // Ignore errors saving recent cities
    }
  }

  void _addToRecentCities(City city) {
    // Remove if already exists (to move it to front)
    _recentCities.removeWhere((c) => c.osmId == city.osmId);
    // Add to front
    _recentCities.insert(0, city);
    // Keep only max recent cities
    if (_recentCities.length > _maxRecentCities) {
      _recentCities.removeLast();
    }
    // Persist to storage
    _saveRecentCities();
  }

  Future<void> _fetchSuggestions(String query) async {
    if (query.isEmpty) {
      // Show only recent cities when field is empty/focused
      setState(() { _suggestions = List.from(_recentCities); _isLoading = false; _errorMessage = null; });
      return;
    }

    // Clear suggestions and show loading when typing
    setState(() { _suggestions = []; _isLoading = true; _errorMessage = null; });

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

    final uri = Uri.parse('http://photon.130.61.31.172.sslip.io/api?q=$query&osm_tag=place:city&osm_tag=place:town&osm_tag=place:village');

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
          final query = textEditingValue.text;

          // Debounce API fetch
          if (_debounce?.isActive ?? false) _debounce!.cancel();
          _debounce = Timer(const Duration(milliseconds: 400), () {
            _fetchSuggestions(query);
          });

          // Show recent cities only when field is empty
          if (query.isEmpty) {
            return List.from(_recentCities);
          }

          // When typing, show only API suggestions (filtered by query)
          final lowerQuery = query.toLowerCase();
          return _suggestions
              .where((c) => c.name.toLowerCase().contains(lowerQuery))
              .toList();
        },
        displayStringForOption: (City option) => option.name,
        onSelected: (City selection) {
          _addToRecentCities(selection);
          widget.onCitySelected(selection);
          FocusScope.of(context).unfocus();
        },
        fieldViewBuilder: (context, fieldController, focusNode, onFieldSubmitted) {
          // Sync external controller with internal one
          fieldController.addListener(() {
            final text = fieldController.text;
            widget.controller.text = text;
            if (text.isEmpty) {
              widget.onCityCleared?.call();
            }
          });
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
