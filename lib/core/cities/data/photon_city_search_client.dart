import 'package:dio/dio.dart';

import '../domain/city.dart';
import 'city_search_client.dart';

/// Photon API implementation of [CitySearchClient]
///
/// Uses a custom Photon-compatible geocoding API to search for cities.
/// Results are filtered to only include entries with a geonameid.
class PhotonCitySearchClient implements CitySearchClient {
  final Dio _dio;

  static const String _defaultBaseUrl =
      'http://photon-like.130.61.31.172.sslip.io';

  PhotonCitySearchClient(this._dio);

  @override
  String get baseUrl => _defaultBaseUrl;

  @override
  Future<List<City>> searchCities({
    required String query,
    required String lang,
    int limit = 10,
    CancelToken? cancelToken,
  }) async {
    final validLang = (lang == 'pl' || lang == 'en') ? lang : 'en';

    final response = await _dio.get<Map<String, dynamic>>(
      '$_defaultBaseUrl/api',
      queryParameters: {
        'q': query,
        'lang': validLang,
        'limit': limit,
      },
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) return [];

    final features = data['features'] as List<dynamic>?;
    if (features == null) return [];

    return features
        .where((f) {
          final props = f['properties'] as Map<String, dynamic>?;
          return props != null && props['geonameid'] != null;
        })
        .map((f) => City.fromPhotonJson(f as Map<String, dynamic>))
        .toList();
  }
}
