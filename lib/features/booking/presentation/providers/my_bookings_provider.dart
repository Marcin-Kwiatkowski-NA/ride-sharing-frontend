import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../domain/booking_presentation.dart';
import '../../domain/booking_ui_model.dart';
import 'ride_booking_providers.dart';

part 'my_bookings_provider.g.dart';

/// Provider for the current user's bookings as UI models.
///
/// Derives from [myBookingDtosProvider] — no additional HTTP call.
/// Auto-disposes when no longer watched (e.g. when My Activity tab is hidden).
@riverpod
Future<List<BookingUiModel>> myBookings(Ref ref) async {
  final dtos = await ref.watch(myBookingDtosProvider.future);
  return BookingPresentation.toUiModels(dtos);
}
