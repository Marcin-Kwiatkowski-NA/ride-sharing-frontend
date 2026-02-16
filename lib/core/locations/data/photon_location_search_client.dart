import 'package:dio/dio.dart';

import '../domain/location.dart';
import 'location_search_client.dart';

/// Photon API implementation of [LocationSearchClient].
///
/// Uses the Photon geocoding API to search for locations.
/// Results are filtered to only include entries with an osm_id.
class PhotonLocationSearchClient implements LocationSearchClient {
  final Dio _dio;

  static const String _defaultBaseUrl = 'https://ac.vamigo.app';

  PhotonLocationSearchClient(this._dio);

  @override
  String get baseUrl => _defaultBaseUrl;

  @override
  Future<List<Location>> searchLocations({
    required String query,
    int limit = 5,
    String? lang,
    CancelToken? cancelToken,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '$_defaultBaseUrl/api',
      queryParameters: {
        'q': query,
        'limit': limit,
        'layer': 'city',
        if (lang != null) 'lang': lang,
      },
      cancelToken: cancelToken,
    );

    final data = response.data;
    if (data == null) return [];

    final features = data['features'] as List<dynamic>?;
    if (features == null) return [];

    final seenNames = <String>{};
    return features
        .where((f) {
          final props = f['properties'] as Map<String, dynamic>?;
          return props != null && props['osm_id'] != null;
        })
        .map((f) => Location.fromPhotonFeature(f as Map<String, dynamic>))
        .where((l) => seenNames.add(l.name))
        .toList();
  }
}
