import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/app_locale_provider.dart';
import 'core/l10n/shared_preferences_provider.dart';
import 'core/network/auth_token_provider.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load before runApp to avoid locale flicker on first frame.
  final prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting();

  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
    child: const MyApp(),
  ));
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
    final locale = ref.watch(appLocaleProvider);

    return MaterialApp.router(
      title: 'Vamos Ride Sharing',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
