import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'stomp_connection_state.dart';
import 'stomp_service_provider.dart';

part 'stomp_connection_state_provider.g.dart';

/// Exposes the STOMP connection state as a watchable stream.
///
/// Seeds with [StompService.connectionState] so late subscribers
/// (e.g. a chat screen opened after STOMP is already connected)
/// immediately get the current value instead of `AsyncLoading`.
@riverpod
Stream<StompConnectionState> stompConnectionState(Ref ref) async* {
  final service = ref.watch(stompServiceControllerProvider);
  yield service.connectionState;
  yield* service.connectionStateStream;
}
