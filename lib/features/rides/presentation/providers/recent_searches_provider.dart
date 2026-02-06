import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/dto/recent_search_snapshot.dart';
import '../../data/recent_searches_repository.dart';

part 'recent_searches_provider.g.dart';

@Riverpod(keepAlive: true)
class RecentSearches extends _$RecentSearches {
  late RecentSearchesRepository _repository;

  @override
  Future<List<RecentSearchSnapshot>> build() async {
    final prefs = await SharedPreferences.getInstance();
    _repository = RecentSearchesRepository(prefs);
    return _repository.load();
  }

  /// Add a search snapshot and update state.
  Future<void> addSearch(RecentSearchSnapshot snapshot) async {
    await _repository.add(snapshot);
    state = AsyncData(_repository.load());
  }

  /// Clear all recent searches.
  Future<void> clearAll() async {
    await _repository.clear();
    state = const AsyncData([]);
  }
}
