import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../routes/router_config.dart';
import '../../routes/routes.dart';

part 'deep_link_handler.g.dart';

@Riverpod(keepAlive: true)
class DeepLinkHandler extends _$DeepLinkHandler {
  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Last processed URI + timestamp for dedupe.
  Uri? _lastUri;
  DateTime? _lastTime;
  static const _dedupeWindow = Duration(seconds: 2);

  @override
  void build() {
    _init();
    ref.onDispose(() {
      _sub?.cancel();
    });
  }

  Future<void> _init() async {
    // Cold start: check initial link
    try {
      final initialUri = await _appLinks.getInitialLink();
      if (initialUri != null) {
        _handleUri(initialUri);
      }
    } catch (e) {
      debugPrint('DeepLinkHandler: failed to get initial link: $e');
    }

    // Warm start: listen for incoming links
    _sub = _appLinks.uriLinkStream.listen(
      _handleUri,
      onError: (e) => debugPrint('DeepLinkHandler: stream error: $e'),
    );
  }

  void _handleUri(Uri uri) {
    // Dedupe guard: skip if same URI within window
    final now = DateTime.now();
    if (_lastUri == uri && _lastTime != null && now.difference(_lastTime!) < _dedupeWindow) {
      return;
    }
    _lastUri = uri;
    _lastTime = now;

    if (uri.path == RoutePaths.verifyResult) {
      final status = uri.queryParameters['status'] ?? '';
      final router = ref.read(routerProvider);
      router.go('${RoutePaths.verifyResult}?status=$status');
    }
    // Ignore unrecognized paths
  }
}
