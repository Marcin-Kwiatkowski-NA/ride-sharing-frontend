import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'dto/recent_search_snapshot.dart';

/// Persists recent search snapshots in SharedPreferences.
class RecentSearchesRepository {
  static const _key = 'recent_searches_v1';
  static const _maxItems = 5;

  final SharedPreferences _prefs;

  RecentSearchesRepository(this._prefs);

  /// Load recent searches. Discards corrupt entries silently.
  List<RecentSearchSnapshot> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final results = <RecentSearchSnapshot>[];
      for (final item in list) {
        try {
          results.add(
            RecentSearchSnapshot.fromStorageJson(item as Map<String, dynamic>),
          );
        } catch (_) {
          // Corrupt entry — skip silently
        }
      }
      return results.take(_maxItems).toList();
    } catch (_) {
      return [];
    }
  }

  /// Add a snapshot. Deduplicates by [isSameSearch], moves to front if exists,
  /// inserts at front if new, trims to [_maxItems].
  Future<void> add(RecentSearchSnapshot snapshot) async {
    final current = load();

    // Remove existing duplicate
    current.removeWhere((s) => s.isSameSearch(snapshot));

    // Insert at front
    current.insert(0, snapshot);

    // Trim
    final trimmed = current.take(_maxItems).toList();

    await _persist(trimmed);
  }

  /// Clear all recent searches.
  Future<void> clear() async {
    await _prefs.remove(_key);
  }

  Future<void> _persist(List<RecentSearchSnapshot> items) async {
    final json = jsonEncode(items.map((s) => s.toStorageJson()).toList());
    await _prefs.setString(_key, json);
  }
}
