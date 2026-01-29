import 'package:dio/dio.dart';

import '../domain/city.dart';

/// Abstract interface for city search operations
abstract class CitySearchClient {
  /// Search for cities matching the query
  ///
  /// [query] - search term (city name)
  /// [lang] - language code for results ("pl" or "en")
  /// [limit] - maximum number of results
  /// [cancelToken] - optional token to cancel the request
  Future<List<City>> searchCities({
    required String query,
    required String lang,
    int limit = 10,
    CancelToken? cancelToken,
  });

  /// Base URL of the search service
  String get baseUrl;
}
