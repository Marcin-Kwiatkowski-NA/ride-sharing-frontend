import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../providers/app_lifecycle_provider.dart';
import '../providers/auth_session_provider.dart';
import 'auth_token_provider.dart';
import 'stomp_service.dart';

part 'stomp_service_provider.g.dart';

/// Owns a single [StompService] instance and manages its lifecycle
/// via explicit [activate]/[deactivate]/[reset] transitions.
///
/// - Login  → [activate] (if also in foreground)
/// - Logout → [reset] (clear subscriptions for fresh session)
/// - Background → [deactivate] (keep subs, reconnect on resume)
/// - Foreground  → [activate] (reconnect + re-subscribe tracked subs)
@Riverpod(keepAlive: true)
class StompServiceController extends _$StompServiceController {
  @override
  StompService build() {
    final service = StompService(
      tokenProvider: () async => ref.read(authTokenProvider)!.accessToken,
    );

    // Auth changes: login → activate, logout → reset
    ref.listen(authSessionKeyProvider, (prev, next) {
      if (next != null && prev == null) {
        _activateIfReady(service);
      } else if (next == null) {
        service.reset();
      }
    });

    // Lifecycle changes: foreground → activate, background → deactivate
    ref.listen(appLifecycleProvider, (prev, next) {
      if (next == AppLifecycleState.resumed) {
        _activateIfReady(service);
      } else if (prev == AppLifecycleState.resumed) {
        service.deactivate();
      }
    });

    // Initial activation if conditions already met
    _activateIfReady(service);

    ref.onDispose(() => service.dispose());
    return service;
  }

  void _activateIfReady(StompService service) {
    final isAuth = ref.read(authSessionKeyProvider) != null;
    final isResumed =
        ref.read(appLifecycleProvider) == AppLifecycleState.resumed;
    if (isAuth && isResumed) service.activate();
  }
}
