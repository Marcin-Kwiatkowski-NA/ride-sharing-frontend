import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';

base class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderObserverContext context,
    Object error,
    StackTrace stackTrace,
  ) {
    final name = context.provider.name ?? context.provider.runtimeType;
    log(
      '$name failed: $error',
      name: 'Provider',
      error: error,
      stackTrace: stackTrace,
    );
  }
}
