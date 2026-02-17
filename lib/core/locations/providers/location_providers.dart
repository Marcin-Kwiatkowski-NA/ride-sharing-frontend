import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/foundation.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/environment_config.dart';
import '../../l10n/app_locale_provider.dart';
import '../data/location_search_client.dart';
import '../data/photon_location_search_client.dart';
import '../repository/location_repository.dart';

part 'location_providers.g.dart';

/// Configuration provider for location repository.
@Riverpod(keepAlive: true)
LocationRepositoryConfig locationConfig(Ref ref) =>
    const LocationRepositoryConfig();

/// Dedicated Dio instance for location search with HTTP caching.
@Riverpod(keepAlive: true)
Future<Dio> locationSearchDio(Ref ref) async {
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  // Hive-based HTTP cache is only available on platforms with a filesystem.
  // On web, we skip the cache interceptor (browser handles its own cache).
  if (!kIsWeb) {
    final cacheDir = await getApplicationCacheDirectory();
    final cacheStore = HiveCacheStore(cacheDir.path);

    final cacheOptions = CacheOptions(
      store: cacheStore,
      policy: CachePolicy.request,
      maxStale: const Duration(days: 3),
      hitCacheOnErrorCodes: [500, 502, 503, 504],
      hitCacheOnNetworkFailure: true,
      keyBuilder: ({
        required Uri url,
        Object? body,
        Map<String, String>? headers,
      }) =>
          url.toString(),
    );

    dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));
  }

  if (EnvironmentConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[LOCATION_DIO] $obj'),
      ),
    );
  }

  return dio;
}

/// Location search client provider.
@Riverpod(keepAlive: true)
Future<LocationSearchClient> locationSearchClient(Ref ref) async {
  final dio = await ref.watch(locationSearchDioProvider.future);
  return PhotonLocationSearchClient(dio, baseUri: EnvironmentConfig.photonUri);
}

/// Location repository provider.
///
/// Rebuilds when the effective locale changes so Photon searches
/// use the correct language.
@riverpod
Future<LocationRepository> locationRepository(Ref ref) async {
  final client = await ref.watch(locationSearchClientProvider.future);
  final config = ref.watch(locationConfigProvider);
  final lang = ref.watch(effectiveLocaleProvider).languageCode;
  return LocationRepository(client, lang: lang, config: config);
}
