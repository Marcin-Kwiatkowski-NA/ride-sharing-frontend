import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../rides/data/ride_repository.dart';
import '../../../rides/domain/ride_presentation.dart';
import '../../domain/offer_ui_model.dart';

part 'offer_detail_provider.g.dart';

/// Provider for a single offer by its composite key.
///
/// Bridges OfferKey to kind-specific repositories.
/// Auto-disposes when no longer used.
@riverpod
Future<OfferUiModel> offerDetail(Ref ref, OfferKey key) async {
  switch (key.kind) {
    case OfferKind.ride:
      final repository = ref.watch(rideRepositoryProvider);
      final dto = await repository.getRideById(key.id);
      return RidePresentation.toUiModel(dto);
    case OfferKind.seat:
      throw UnimplementedError('Seat offers not yet supported');
  }
}
