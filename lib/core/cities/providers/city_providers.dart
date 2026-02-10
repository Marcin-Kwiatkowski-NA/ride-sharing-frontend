import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/widgets.dart';
import 'package:http_cache_hive_store/http_cache_hive_store.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../config/environment_config.dart';
import '../../l10n/app_locale_provider.dart';
import '../data/city_search_client.dart';
import '../data/photon_city_search_client.dart';
import '../repository/city_repository.dart';

part 'city_providers.g.dart';

/// Configuration provider for city repository
@Riverpod(keepAlive: true)
CityRepositoryConfig cityConfig(Ref ref) => const CityRepositoryConfig();

/// Dedicated Dio instance for city search with HTTP caching
@Riverpod(keepAlive: true)
Future<Dio> citySearchDio(Ref ref) async {
  final cacheDir = await getApplicationCacheDirectory();
  final cacheStore = HiveCacheStore(cacheDir.path);

  final cacheOptions = CacheOptions(
    store: cacheStore,
    policy: CachePolicy.request,
    maxStale: const Duration(days: 3),
    hitCacheOnErrorCodes: [500, 502, 503, 504],
    hitCacheOnNetworkFailure: true,
    keyBuilder: ({required Uri url, Object? body, Map<String, String>? headers}) =>
        url.toString(),
  );

  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(DioCacheInterceptor(options: cacheOptions));

  if (EnvironmentConfig.isDevelopment) {
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint('[CITY_DIO] $obj'),
      ),
    );
  }

  return dio;
}

/// City search client provider
@Riverpod(keepAlive: true)
Future<CitySearchClient> citySearchClient(Ref ref) async {
  final dio = await ref.watch(citySearchDioProvider.future);
  return PhotonCitySearchClient(dio);
}

/// City repository provider
@Riverpod(keepAlive: true)
Future<CityRepository> cityRepository(Ref ref) async {
  final client = await ref.watch(citySearchClientProvider.future);
  final config = ref.watch(cityConfigProvider);
  return CityRepository(client, config: config);
}

/// Search language derived from the app's effective locale preference.
///
/// Uses [effectiveLocaleProvider] which accounts for the user's language
/// setting (System / EN / PL) rather than the raw device locale.
@riverpod
String citySearchLang(Ref ref) {
  final locale = ref.watch(effectiveLocaleProvider);
  return locale.languageCode == 'pl' ? 'pl' : 'en';
}
