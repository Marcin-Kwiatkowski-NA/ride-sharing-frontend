import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_provider.g.dart';

/// Provider for the current navigation tab index.
/// 0 = Rides, 1 = Passengers, 2 = Profile
///
/// Uses keepAlive to persist navigation state across the app lifecycle.
@Riverpod(keepAlive: true)
class NavigationIndex extends _$NavigationIndex {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}
