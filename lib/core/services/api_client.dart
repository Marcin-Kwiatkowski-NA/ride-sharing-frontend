import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vamigo/config/environment_config.dart';
import 'package:vamigo/core/utils/jwt_decoder.dart';
import 'package:vamigo/core/utils/exceptions.dart';

/// Centralized HTTP client with automatic token injection and error handling
///
/// Features:
/// - Automatic Bearer token injection from secure storage
/// - Token expiration check before requests
/// - 401 response handling with callback
/// - Error transformation to custom exceptions
/// - Centralized base URL from EnvironmentConfig
class ApiClient {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _httpClient = http.Client();

  /// Callback for when token expires (401 response)
  /// Set this to AuthProvider.handleTokenExpiration
  VoidCallback? onTokenExpired;

  /// Base URL for all API requests
  String get baseUrl => EnvironmentConfig.apiBaseUrl;

  /// GET request
  Future<http.Response> get(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    final uri = _buildUri(path, queryParams);
    final requestHeaders = await _buildHeaders(headers);

    try {
      final response = await _httpClient.get(uri, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST request
  Future<http.Response> post(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, null);
    final requestHeaders = await _buildHeaders(headers);
    final jsonBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await _httpClient.post(
        uri,
        headers: requestHeaders,
        body: jsonBody,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT request
  Future<http.Response> put(
    String path, {
    Object? body,
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, null);
    final requestHeaders = await _buildHeaders(headers);
    final jsonBody = body != null ? jsonEncode(body) : null;

    try {
      final response = await _httpClient.put(
        uri,
        headers: requestHeaders,
        body: jsonBody,
      );
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE request
  Future<http.Response> delete(
    String path, {
    Map<String, String>? headers,
  }) async {
    final uri = _buildUri(path, null);
    final requestHeaders = await _buildHeaders(headers);

    try {
      final response = await _httpClient.delete(uri, headers: requestHeaders);
      return _handleResponse(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Build full URI from path and query parameters
  Uri _buildUri(String path, Map<String, String>? queryParams) {
    final fullUrl = path.startsWith('http') ? path : '$baseUrl$path';
    final uri = Uri.parse(fullUrl);

    if (queryParams != null && queryParams.isNotEmpty) {
      return uri.replace(queryParameters: queryParams);
    }
    return uri;
  }

  /// Build request headers with automatic token injection
  Future<Map<String, String>> _buildHeaders([
    Map<String, String>? customHeaders,
  ]) async {
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Accept': 'application/json',
      ...?customHeaders,
    };

    // Add Bearer token if available
    final token = await _storage.read(key: 'access_token');
    if (token != null) {
      // Check if token is expired before sending
      if (JwtDecoder.isTokenExpired(token)) {
        debugPrint('ApiClient: Token expired before request');
        onTokenExpired?.call();
        throw TokenExpiredException('Token has expired');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  /// Handle HTTP response and transform errors
  http.Response _handleResponse(http.Response response) {
    debugPrint('ApiClient: ${response.request?.method} ${response.request?.url} -> ${response.statusCode}');

    // Handle 401 - Unauthorized (token expired or invalid)
    if (response.statusCode == 401) {
      debugPrint('ApiClient: 401 Unauthorized - Token expired');
      onTokenExpired?.call();
      throw TokenExpiredException('Authentication failed');
    }

    // Handle 403 - Forbidden
    if (response.statusCode == 403) {
      throw ForbiddenException(_parseErrorMessage(response) ?? 'Access denied');
    }

    // Handle 404 - Not Found
    if (response.statusCode == 404) {
      throw NotFoundException(_parseErrorMessage(response) ?? 'Resource not found');
    }

    // Handle 5xx - Server errors
    if (response.statusCode >= 500) {
      throw ServerException(
        _parseErrorMessage(response) ?? 'Server error',
        response.statusCode,
      );
    }

    // Handle other 4xx errors
    if (response.statusCode >= 400) {
      throw ApiException(
        statusCode: response.statusCode,
        message: _parseErrorMessage(response) ?? 'Request failed',
      );
    }

    return response;
  }

  /// Parse error message from response body
  String? _parseErrorMessage(http.Response response) {
    if (response.body.isEmpty) return null;

    try {
      final data = jsonDecode(response.body);
      if (data is Map) {
        return data['message'] ?? data['error'] ?? data.toString();
      }
      return data.toString();
    } catch (e) {
      return response.body;
    }
  }

  /// Transform exceptions to custom types
  Exception _handleError(dynamic error) {
    if (error is TokenExpiredException ||
        error is ApiException ||
        error is NetworkException ||
        error is ForbiddenException ||
        error is NotFoundException ||
        error is ServerException) {
      return error as Exception;
    }

    if (error is SocketException) {
      return NetworkException('No internet connection', error);
    }

    if (error is http.ClientException) {
      return NetworkException('Network error: ${error.message}', error);
    }

    return NetworkException('An unexpected error occurred: $error', error);
  }

  /// Dispose the HTTP client
  void dispose() {
    _httpClient.close();
  }
}
