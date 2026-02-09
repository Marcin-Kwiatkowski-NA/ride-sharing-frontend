import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../domain/public_profile_data.dart';

part 'public_profile_cache.g.dart';

@Riverpod(keepAlive: true)
class PublicProfileCache extends _$PublicProfileCache {
  @override
  Map<int, PublicProfileData> build() => {};

  void put(PublicProfileData data) {
    state = {...state, data.userId: data};
  }
}
