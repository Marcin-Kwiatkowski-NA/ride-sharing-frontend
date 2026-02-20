import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/booking_repository.dart';
import '../../domain/booking_presentation.dart';
import '../../domain/booking_ui_model.dart';

part 'my_bookings_provider.g.dart';

/// Provider for the current user's bookings as a passenger.
///
/// Auto-disposes when no longer watched (e.g. when My Activity tab is hidden).
@riverpod
Future<List<BookingUiModel>> myBookings(Ref ref) async {
  final repo = ref.watch(bookingRepositoryProvider);
  final dtos = await repo.getMyBookings();
  return BookingPresentation.toUiModels(dtos);
}
