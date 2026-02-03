import 'package:freezed_annotation/freezed_annotation.dart';

part 'paginated_response.freezed.dart';

/// Generic wrapper for Spring Boot Page responses.
@freezed
sealed class PaginatedResponse<T> with _$PaginatedResponse<T> {
  const factory PaginatedResponse({
    required List<T> content,
    required int totalElements,
    required int totalPages,
    required int currentPage,
    required bool last,
  }) = _PaginatedResponse<T>;
}
