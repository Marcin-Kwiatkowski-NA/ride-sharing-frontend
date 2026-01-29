import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/city_search_client.dart';
import '../domain/city.dart';

/// Configuration for [CityRepository]
class CityRepositoryConfig {
  final int minQueryLength;
  final int maxRecentCities;
  final int maxDisplayItems;

  const CityRepositoryConfig({
    this.minQueryLength = 2,
    this.maxRecentCities = 10,
    this.maxDisplayItems = 10,
  });
}

/// Repository combining API search with recent cities storage
class CityRepository {
  final CitySearchClient _client;
  final CityRepositoryConfig config;

  static const String _recentCitiesKeyV2 = 'recent_cities_v2';

  List<City>? _recentCitiesCache;

  CityRepository(this._client, {this.config = const CityRepositoryConfig()});

  /// Search for cities, combining recent cities with API results
  ///
  /// - Empty query: returns recent cities only
  /// - Query < minQueryLength: filters recent cities only
  /// - Query >= minQueryLength: API call + combined with recents
  Future<List<City>> searchCities({
    required String query,
    required String lang,
    CancelToken? cancelToken,
  }) async {
    final recents = await _getRecentCities();

    if (query.isEmpty) {
      return recents.take(config.maxDisplayItems).toList();
    }

    final lowerQuery = query.toLowerCase();

    if (query.length < config.minQueryLength) {
      return _filterRecents(recents, lowerQuery);
    }

    try {
      final apiResults = await _client.searchCities(
        query: query,
        lang: lang,
        limit: config.maxDisplayItems,
        cancelToken: cancelToken,
      );

      return _combineAndSort(recents, apiResults, lowerQuery);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel) {
        rethrow;
      }
      // On network error, fall back to filtered recents
      return _filterRecents(recents, lowerQuery);
    }
  }

  /// Add a city to recent selections
  Future<void> addToRecent(City city) async {
    final recents = await _getRecentCities();

    // Remove if exists (to move to front)
    recents.removeWhere((c) => c.placeId == city.placeId);

    // Add to front
    recents.insert(0, city);

    // Trim to max
    if (recents.length > config.maxRecentCities) {
      recents.removeRange(config.maxRecentCities, recents.length);
    }

    _recentCitiesCache = recents;
    await _saveRecentCities(recents);
  }

  /// Get recent cities from storage
  Future<List<City>> getRecentCities() async {
    return List.unmodifiable(await _getRecentCities());
  }

  Future<List<City>> _getRecentCities() async {
    if (_recentCitiesCache != null) {
      return _recentCitiesCache!;
    }

    final prefs = await SharedPreferences.getInstance();

    final v2Json = prefs.getString(_recentCitiesKeyV2);
    if (v2Json != null) {
      try {
        final list = json.decode(v2Json) as List<dynamic>;
        _recentCitiesCache = list
            .map((j) => City.fromStorageJson(j as Map<String, dynamic>))
            .toList();
        return _recentCitiesCache!;
      } catch (_) {
        // Corrupted data
      }
    }

    _recentCitiesCache = [];
    return _recentCitiesCache!;
  }

  Future<void> _saveRecentCities(List<City> cities) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = cities.map((c) => c.toStorageJson()).toList();
    await prefs.setString(_recentCitiesKeyV2, json.encode(jsonList));
  }

  List<City> _filterRecents(List<City> recents, String lowerQuery) {
    final filtered = recents
        .where((c) => c.name.toLowerCase().contains(lowerQuery))
        .toList();

    filtered.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aPrefix = aName.startsWith(lowerQuery);
      final bPrefix = bName.startsWith(lowerQuery);

      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;

      final aPop = a.population ?? 0;
      final bPop = b.population ?? 0;
      if (aPop != bPop) return bPop.compareTo(aPop);

      final nameCompare = aName.compareTo(bName);
      if (nameCompare != 0) return nameCompare;

      return a.placeId.compareTo(b.placeId);
    });

    return filtered.take(config.maxDisplayItems).toList();
  }

  List<City> _combineAndSort(
    List<City> recents,
    List<City> apiResults,
    String lowerQuery,
  ) {
    final seen = <int>{};
    final combined = <City>[];

    // Filter and add matching recents first
    for (final city in recents) {
      if (city.name.toLowerCase().contains(lowerQuery)) {
        if (seen.add(city.placeId)) {
          combined.add(city);
        }
      }
    }

    // Add API results, deduplicating
    for (final city in apiResults) {
      if (seen.add(city.placeId)) {
        combined.add(city);
      }
    }

    // Sort: prefix match first, then by population (desc), then alphabetically (case-insensitive), then placeId
    combined.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aPrefix = aName.startsWith(lowerQuery);
      final bPrefix = bName.startsWith(lowerQuery);

      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;

      final aPop = a.population ?? 0;
      final bPop = b.population ?? 0;
      if (aPop != bPop) return bPop.compareTo(aPop);

      final nameCompare = aName.compareTo(bName);
      if (nameCompare != 0) return nameCompare;

      return a.placeId.compareTo(b.placeId);
    });

    return combined.take(config.maxDisplayItems).toList();
  }
}
