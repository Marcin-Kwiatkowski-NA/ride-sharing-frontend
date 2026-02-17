import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/l10n/app_locale_provider.dart';
import 'core/l10n/shared_preferences_provider.dart';
import 'core/deep_link/deep_link_handler.dart';
import 'core/network/auth_token_provider.dart';
import 'core/providers/app_provider_observer.dart';
import 'core/providers/auth_notifier.dart';
import 'core/theme/app_theme.dart';
import 'l10n/generated/app_localizations.dart';
import 'routes/router_config.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-load before runApp to avoid locale flicker on first frame.
  final prefs = await SharedPreferences.getInstance();
  await initializeDateFormatting();

  runApp(ProviderScope(
    observers: [AppProviderObserver()],
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
    // Initialize deep link handler early to catch cold-start links
    ref.read(deepLinkHandlerProvider);
  }

  Future<void> _initializeToken() async {
    final tokenPair = await loadTokensFromStorage();
    if (mounted) {
      ref.read(authTokenProvider.notifier).hydrate(tokenPair);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Auth coordinator: when token store is externally cleared (e.g. by
    // the Dio interceptor on unrecoverable auth failure), transition
    // auth state to unauthenticated.
    ref.listen(authTokenProvider, (prev, next) {
      if (prev != null && next == null) {
        final authState = ref.read(authProvider);
        if (authState.isAuthenticated) {
          ref.read(authProvider.notifier).onSessionExpired();
        }
      }
    });

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
      localeListResolutionCallback: (locales, supported) {
        if (locale != null) return locale;
        if (locales != null) {
          for (final l in locales) {
            final match = supported.where(
              (s) => s.languageCode == l.languageCode,
            );
            if (match.isNotEmpty) return match.first;
          }
        }
        return supported.first;
      },
    );
  }
}
