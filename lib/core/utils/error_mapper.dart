import 'package:dio/dio.dart';
import '../error/failure.dart';

class ErrorMapper {
  static Failure map(Object error) {
    return switch (error) {
      DioException e => _mapDioError(e),
      Failure f => f,
      _ => UnknownFailure(error),
    };
  }

  static Failure _mapDioError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.connectionError =>
        const NetworkFailure(),
      DioExceptionType.badResponse => _mapStatusError(
          error.response?.statusCode,
          error.response?.data,
        ),
      _ => const ServerFailure('Something went wrong'),
    };
  }

  static Failure _mapStatusError(int? statusCode, dynamic data) {
    return switch (statusCode) {
      401 => const AuthFailure(),
      500 => const ServerFailure('Server internal error', statusCode: 500),
      _ => ServerFailure(
          data is Map
              ? (data['message'] ?? 'Unexpected error')
              : 'Unexpected server error',
        ),
    };
  }
}
