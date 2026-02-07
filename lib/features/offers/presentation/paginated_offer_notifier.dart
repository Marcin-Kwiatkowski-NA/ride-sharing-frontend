import '../../offers/domain/offer_ui_model.dart';

/// State for a paginated offers list.
///
/// Reusable base pattern for any offer kind's pagination.
class PaginatedOfferState {
  final List<OfferUiModel> offers;
  final bool isLoading;
  final bool hasMore;
  final Object? error;
  final int currentPage;

  const PaginatedOfferState({
    this.offers = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.error,
    this.currentPage = 0,
  });

  PaginatedOfferState copyWith({
    List<OfferUiModel>? offers,
    bool? isLoading,
    bool? hasMore,
    Object? error,
    int? currentPage,
  }) {
    return PaginatedOfferState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      error: error,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}
