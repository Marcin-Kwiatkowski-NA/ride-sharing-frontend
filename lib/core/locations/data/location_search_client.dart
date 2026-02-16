import 'package:dio/dio.dart';

import '../domain/location.dart';

/// Abstract interface for location search operations.
abstract class LocationSearchClient {
  Future<List<Location>> searchLocations({
    required String query,
    int limit = 5,
    String? lang,
    CancelToken? cancelToken,
  });

  Uri get baseUri;
}
