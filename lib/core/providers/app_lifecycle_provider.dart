import 'package:flutter/widgets.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_lifecycle_provider.g.dart';

/// Exposes [AppLifecycleState] to Riverpod.
///
/// On mobile: maps to iOS/Android lifecycle (resumed, paused, etc.).
/// On web: maps to page visibility (visibilitychange).
///
/// Used by [StompServiceController] to gate the WebSocket connection
/// on foreground state — background sockets drain battery and get
/// killed by mobile OSes.
@Riverpod(keepAlive: true)
class AppLifecycle extends _$AppLifecycle {
  AppLifecycleListener? _listener;

  @override
  AppLifecycleState build() {
    _listener = AppLifecycleListener(
      onStateChange: (newState) => state = newState,
    );
    ref.onDispose(() => _listener?.dispose());
    return WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed;
  }
}
