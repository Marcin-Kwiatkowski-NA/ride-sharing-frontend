import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/location_search_client.dart';
import '../domain/location.dart';

/// Configuration for [LocationRepository].
class LocationRepositoryConfig {
  final int minQueryLength;
  final int maxRecentLocations;
  final int maxDisplayItems;

  const LocationRepositoryConfig({
    this.minQueryLength = 2,
    this.maxRecentLocations = 10,
    this.maxDisplayItems = 10,
  });
}

/// Repository combining API search with recent locations storage.
class LocationRepository {
  final LocationSearchClient _client;
  final LocationRepositoryConfig config;

  static const String _recentLocationsKey = 'recent_locations_v1';

  List<Location>? _recentLocationsCache;

  LocationRepository(
    this._client, {
    this.config = const LocationRepositoryConfig(),
  });

  /// Search for locations, combining recent locations with API results.
  ///
  /// - Empty query: returns recent locations only
  /// - Query < minQueryLength: filters recent locations only
  /// - Query >= minQueryLength: API call + combined with recents
  Future<List<Location>> searchLocations({
    required String query,
    CancelToken? cancelToken,
  }) async {
    final recents = await _getRecentLocations();

    if (query.isEmpty) {
      return recents.take(config.maxDisplayItems).toList();
    }

    final lowerQuery = query.toLowerCase();

    if (query.length < config.minQueryLength) {
      return _filterRecents(recents, lowerQuery);
    }

    try {
      final apiResults = await _client.searchLocations(
        query: query,
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

  /// Add a location to recent selections.
  Future<void> addToRecent(Location location) async {
    final recents = await _getRecentLocations();

    // Remove if exists (to move to front)
    recents.removeWhere((l) => l.osmId == location.osmId);

    // Add to front
    recents.insert(0, location);

    // Trim to max
    if (recents.length > config.maxRecentLocations) {
      recents.removeRange(config.maxRecentLocations, recents.length);
    }

    _recentLocationsCache = recents;
    await _saveRecentLocations(recents);
  }

  /// Get recent locations from storage.
  Future<List<Location>> getRecentLocations() async {
    return List.unmodifiable(await _getRecentLocations());
  }

  Future<List<Location>> _getRecentLocations() async {
    if (_recentLocationsCache != null) {
      return _recentLocationsCache!;
    }

    final prefs = await SharedPreferences.getInstance();

    final jsonStr = prefs.getString(_recentLocationsKey);
    if (jsonStr != null) {
      try {
        final list = json.decode(jsonStr) as List<dynamic>;
        _recentLocationsCache = list
            .map((j) => Location.fromStorageJson(j as Map<String, dynamic>))
            .toList();
        return _recentLocationsCache!;
      } catch (_) {
        // Corrupted data
      }
    }

    _recentLocationsCache = [];
    return _recentLocationsCache!;
  }

  Future<void> _saveRecentLocations(List<Location> locations) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = locations.map((l) => l.toStorageJson()).toList();
    await prefs.setString(_recentLocationsKey, json.encode(jsonList));
  }

  List<Location> _filterRecents(List<Location> recents, String lowerQuery) {
    final filtered = recents
        .where((l) => l.name.toLowerCase().contains(lowerQuery))
        .toList();

    filtered.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aPrefix = aName.startsWith(lowerQuery);
      final bPrefix = bName.startsWith(lowerQuery);

      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;

      final nameCompare = aName.compareTo(bName);
      if (nameCompare != 0) return nameCompare;

      return a.osmId.compareTo(b.osmId);
    });

    return filtered.take(config.maxDisplayItems).toList();
  }

  List<Location> _combineAndSort(
    List<Location> recents,
    List<Location> apiResults,
    String lowerQuery,
  ) {
    final seen = <int>{};
    final combined = <Location>[];

    // Filter and add matching recents first
    for (final location in recents) {
      if (location.name.toLowerCase().contains(lowerQuery)) {
        if (seen.add(location.osmId)) {
          combined.add(location);
        }
      }
    }

    // Add API results, deduplicating
    for (final location in apiResults) {
      if (seen.add(location.osmId)) {
        combined.add(location);
      }
    }

    // Sort: prefix match first, then alphabetically, then osmId tiebreaker
    combined.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      final aPrefix = aName.startsWith(lowerQuery);
      final bPrefix = bName.startsWith(lowerQuery);

      if (aPrefix != bPrefix) return aPrefix ? -1 : 1;

      final nameCompare = aName.compareTo(bName);
      if (nameCompare != 0) return nameCompare;

      return a.osmId.compareTo(b.osmId);
    });

    return combined.take(config.maxDisplayItems).toList();
  }
}
