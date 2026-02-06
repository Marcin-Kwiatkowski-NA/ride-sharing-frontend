import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'search_mode_provider.g.dart';

enum SearchMode { rides, passengers }

@Riverpod(keepAlive: true)
class SearchModeNotifier extends _$SearchModeNotifier {
  @override
  SearchMode build() => SearchMode.rides;

  void setMode(SearchMode mode) => state = mode;

  void toggle() {
    state = state == SearchMode.rides
        ? SearchMode.passengers
        : SearchMode.rides;
  }
}
