import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:ui';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../config/environment_config.dart';
import '../../features/chat/data/dto/stomp_error_dto.dart';
import 'stomp_connection_state.dart';

/// Tracked subscription entry for auto-resubscribe on reconnect.
class _TrackedSub {
  final String destination;
  final void Function(StompFrame) callback;

  /// The current STOMP unsubscribe function (null when disconnected).
  dynamic currentUnsub;

  _TrackedSub(this.destination, this.callback);
}

/// STOMP WebSocket client with reconnect-aware subscription tracking.
///
/// Lifecycle:
/// - [activate]   → connect (idempotent)
/// - [deactivate]  → disconnect, keep subscription registry (background)
/// - [reset]       → disconnect + clear registry, streams stay open (logout)
/// - [dispose]     → reset + close streams (final teardown)
///
/// Subscriptions are tracked internally. On reconnect, all tracked
/// subscriptions are automatically re-subscribed via [_onConnect].
class StompService {
  final Future<String> Function() _tokenProvider;
  final bool _active;

  StompClient? _client;
  bool _isActive = false;

  final _subscriptions = <String, _TrackedSub>{};
  final _stateCtrl = StreamController<StompConnectionState>.broadcast();
  final _errorCtrl = StreamController<StompErrorDto>.broadcast();

  /// Last emitted connection state — allows late subscribers to read
  /// the current value without relying on broadcast stream replay.
  StompConnectionState _lastState = StompConnectionState.disconnected;
  StompConnectionState get connectionState => _lastState;

  /// Mutable headers map — updated in [_onBeforeConnect] with fresh JWT.
  final _connectHeaders = <String, String>{};

  StompService({required Future<String> Function() tokenProvider})
      : _tokenProvider = tokenProvider,
        _active = true;

  /// Creates an inactive service that no-ops on all methods.
  StompService.inactive()
      : _tokenProvider = (() async => ''),
        _active = false;

  Stream<StompConnectionState> get connectionStateStream => _stateCtrl.stream;
  Stream<StompErrorDto> get errorStream => _errorCtrl.stream;

  /// Connect the STOMP client. Idempotent — no-op if already active.
  void activate() {
    if (!_active || _isActive) return;
    _isActive = true;
    dev.log('activate: connecting to ${EnvironmentConfig.wsBaseUrl}/ws', name: 'StompService');
    _emitState(StompConnectionState.connecting);

    _client = StompClient(
      config: StompConfig(
        url: '${EnvironmentConfig.wsBaseUrl}/ws',
        stompConnectHeaders: _connectHeaders,
        beforeConnect: _onBeforeConnect,
        onConnect: _onConnect,
        onDisconnect: _onDisconnect,
        onStompError: _onStompError,
        onWebSocketError: _onWebSocketError,
        reconnectDelay: const Duration(seconds: 5),
        heartbeatOutgoing: const Duration(seconds: 10),
        heartbeatIncoming: const Duration(seconds: 10),
      ),
    );
    _client!.activate();
  }

  /// Disconnect but keep subscription registry for re-subscribe on
  /// next [activate]. Used for background transitions.
  void deactivate() {
    if (!_isActive) return;
    _isActive = false;

    // Clear active unsub handles (connection is going away)
    for (final sub in _subscriptions.values) {
      sub.currentUnsub = null;
    }

    _client?.deactivate();
    _client = null;
    _emitState(StompConnectionState.disconnected);
  }

  /// Disconnect and clear subscription registry. Streams stay open
  /// (same instance reused across logout/login). Used for logout.
  void reset() {
    deactivate();
    _subscriptions.clear();
  }

  /// Full teardown: reset + close stream controllers.
  /// Called only from provider's ref.onDispose.
  void dispose() {
    reset();
    _stateCtrl.close();
    _errorCtrl.close();
  }

  /// Subscribe to a STOMP destination with auto-resubscribe on reconnect.
  ///
  /// Returns a [VoidCallback] that unsubscribes AND removes the
  /// destination from the tracking registry.
  VoidCallback subscribe(
    String destination,
    void Function(StompFrame) callback,
  ) {
    // Track for reconnect
    final tracked = _TrackedSub(destination, callback);
    _subscriptions[destination] = tracked;

    // Only subscribe immediately when the STOMP handshake is complete.
    // _isActive is true as soon as activate() is called (before connect),
    // so we check _lastState instead to avoid StompBadStateException.
    final canSubNow = _lastState == StompConnectionState.connected && _client != null;
    dev.log(
      'subscribe($destination): immediate=$canSubNow, lastState=$_lastState, '
      'client=${_client != null}, tracked=${_subscriptions.length}',
      name: 'StompService',
    );
    if (canSubNow) {
      tracked.currentUnsub = _client!.subscribe(
        destination: destination,
        callback: callback,
      );
    }

    // Return untrack + unsub function
    return () {
      _subscriptions.remove(destination);
      if (tracked.currentUnsub != null) {
        tracked.currentUnsub(unsubscribeHeaders: <String, String>{});
        tracked.currentUnsub = null;
      }
    };
  }

  /// Send a message to a STOMP destination.
  void send(String destination, {String? body}) {
    if (!_isActive || _client == null) return;
    _client!.send(
      destination: destination,
      body: body,
    );
  }

  void _emitState(StompConnectionState s) {
    _lastState = s;
    _stateCtrl.add(s);
  }

  // -- Lifecycle callbacks --------------------------------------------------

  Future<void> _onBeforeConnect() async {
    final token = await _tokenProvider();
    _connectHeaders['Authorization'] = 'Bearer $token';
  }

  void _onConnect(StompFrame frame) {
    _emitState(StompConnectionState.connected);

    dev.log(
      'onConnect: re-subscribing ${_subscriptions.length} tracked destinations: '
      '${_subscriptions.keys.toList()}',
      name: 'StompService',
    );
    // Re-subscribe all tracked destinations
    for (final sub in _subscriptions.values) {
      if (_client == null) break;
      sub.currentUnsub = _client!.subscribe(
        destination: sub.destination,
        callback: sub.callback,
      );
    }

    // Subscribe to backend error queue
    _client?.subscribe(
      destination: '/user/queue/errors',
      callback: _onErrorFrame,
    );
  }

  void _onDisconnect(StompFrame frame) {
    if (!_isActive) return; // Already handled by deactivate()
    _emitState(StompConnectionState.disconnected);

    // Clear unsub handles (stale after disconnect)
    for (final sub in _subscriptions.values) {
      sub.currentUnsub = null;
    }
  }

  void _onStompError(StompFrame frame) {
    dev.log('STOMP error: ${frame.body}', name: 'StompService');
    _emitState(StompConnectionState.error);
    if (frame.body != null) {
      try {
        final json = jsonDecode(frame.body!) as Map<String, dynamic>;
        _errorCtrl.add(StompErrorDto.fromJson(json));
      } catch (_) {
        _errorCtrl.add(StompErrorDto(
          code: 'STOMP_ERROR',
          message: frame.body ?? 'Unknown STOMP error',
        ));
      }
    }
  }

  void _onWebSocketError(dynamic error) {
    dev.log('WebSocket error: $error', name: 'StompService');
    _errorCtrl.add(StompErrorDto(
      code: 'WEBSOCKET_ERROR',
      message: error.toString(),
    ));
  }

  void _onErrorFrame(StompFrame frame) {
    if (frame.body == null) return;
    try {
      final json = jsonDecode(frame.body!) as Map<String, dynamic>;
      _errorCtrl.add(StompErrorDto.fromJson(json));
    } catch (_) {
      // Ignore malformed error frames
    }
  }
}
