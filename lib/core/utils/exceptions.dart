/// Custom exception for token expiration
class TokenExpiredException implements Exception {
  final String message;

  TokenExpiredException(this.message);

  @override
  String toString() => 'TokenExpiredException: $message';
}

/// Custom exception for API errors with status codes
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final dynamic details;

  ApiException({
    required this.statusCode,
    required this.message,
    this.details,
  });

  @override
  String toString() => 'ApiException($statusCode): $message${details != null ? ' - $details' : ''}';

  /// Check if this is a client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  /// Check if this is a server error (5xx)
  bool get isServerError => statusCode >= 500;

  /// Check if this is an unauthorized error (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if this is a forbidden error (403)
  bool get isForbidden => statusCode == 403;

  /// Check if this is a not found error (404)
  bool get isNotFound => statusCode == 404;
}

/// Custom exception for network connectivity issues
class NetworkException implements Exception {
  final String message;
  final dynamic originalException;

  NetworkException(this.message, [this.originalException]);

  @override
  String toString() => 'NetworkException: $message${originalException != null ? ' (${originalException.toString()})' : ''}';
}

/// Custom exception for unauthenticated access
class UnauthenticatedException implements Exception {
  final String message;

  UnauthenticatedException(this.message);

  @override
  String toString() => 'UnauthenticatedException: $message';
}

/// Custom exception for forbidden access
class ForbiddenException implements Exception {
  final String message;

  ForbiddenException(this.message);

  @override
  String toString() => 'ForbiddenException: $message';
}

/// Custom exception for not found resources
class NotFoundException implements Exception {
  final String message;

  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Custom exception for server errors
class ServerException implements Exception {
  final String message;
  final int? statusCode;

  ServerException(this.message, [this.statusCode]);

  @override
  String toString() => 'ServerException${statusCode != null ? '($statusCode)' : ''}: $message';
}
