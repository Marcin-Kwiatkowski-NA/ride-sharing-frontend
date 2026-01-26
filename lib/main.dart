import 'package:blablafront/features/navigation/main_layout.dart';
import 'package:blablafront/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blablafront/core/network/auth_token_provider.dart';
import 'package:blablafront/routes/app_router.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool _tokenInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeToken();
  }

  Future<void> _initializeToken() async {
    // Load token from secure storage and sync to Riverpod
    final token = await loadTokenFromStorage();
    if (mounted) {
      ref.read(authTokenProvider.notifier).setToken(token);
      setState(() => _tokenInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait for token to be initialized before rendering
    if (!_tokenInitialized) {
      return MaterialApp(
        title: 'Vamos Ride Sharing',
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Vamos Ride Sharing',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const MainLayout(),
    );
  }
}
