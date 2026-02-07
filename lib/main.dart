import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/network/auth_token_provider.dart';
import 'core/theme/app_theme.dart';
import 'routes/router_config.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  @override
  void initState() {
    super.initState();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    final tokenPair = await loadTokensFromStorage();
    if (mounted) {
      ref.read(authTokenProvider.notifier).setTokenPair(tokenPair);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Single MaterialApp.router - splash screen handles loading via redirect
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Vamos Ride Sharing',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}
