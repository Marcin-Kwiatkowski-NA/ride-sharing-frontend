import 'dart:convert';
import 'dart:ui';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../../../core/network/stomp_connection_state.dart';
import '../../../../core/network/stomp_connection_state_provider.dart';
import '../../../../core/network/stomp_service_provider.dart';
import '../../../offers/domain/offer_ui_model.dart';
import '../../../offers/presentation/providers/offer_detail_provider.dart';
import '../../data/dto/booking_notification_dto.dart';
import 'ride_booking_providers.dart';

part 'booking_event_handler.g.dart';

/// Global STOMP subscription for booking events.
///
/// Subscribes to `/user/queue/bookings` and invalidates the relevant
/// Riverpod providers when events arrive. Also exposes the latest event
/// as state so screens can show contextual snackbars via `ref.listen`.
///
/// Kept alive so the subscription persists across screen navigations.
/// Initialized from [MainLayout] when the user is authenticated.
///
/// Reconnection is handled by [StompService] which auto-resubscribes
/// tracked subscriptions on reconnect. Mobile foreground/background
/// transitions are handled by [StompServiceController] via
/// [appLifecycleProvider].
@Riverpod(keepAlive: true)
class BookingEventHandler extends _$BookingEventHandler {
  VoidCallback? _unsubscribe;

  /// Dedup: track last processed (bookingId, statusValue, eventType).
  (int, String, String)? _lastProcessed;

  @override
  BookingNotificationDto? build() {
    ref.listen(stompConnectionStateProvider, (prev, next) {
      if (next.value == StompConnectionState.connected) {
        _subscribe();
      }
    });

    ref.onDispose(() {
      _unsubscribe?.call();
      _unsubscribe = null;
    });

    _subscribe();
    return null;
  }

  void _subscribe() {
    // Guard: don't create duplicate subscriptions
    if (_unsubscribe != null) return;
    final service = ref.read(stompServiceControllerProvider);
    _unsubscribe = service.subscribe('/user/queue/bookings', _onFrame);
  }

  void _onFrame(StompFrame frame) {
    if (frame.body == null || !ref.mounted) return;

    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      final event = BookingNotificationDto.fromJson(json);

      // Dedup: skip if identical to last processed event
      final key = (event.bookingId, event.status.value, event.eventType);
      if (key == _lastProcessed) return;
      _lastProcessed = key;

      state = event;

      // Targeted invalidation
      ref.invalidate(myBookingDtosProvider);
      ref.invalidate(rideBookingsProvider(event.rideId));
      if (['CONFIRMED', 'CANCELLED', 'REJECTED'].contains(event.eventType)) {
        ref.invalidate(
          offerDetailProvider(OfferKey(OfferKind.ride, event.rideId)),
        );
      }
    } catch (_) {
      // Ignore malformed booking event frames
    }
  }
}
