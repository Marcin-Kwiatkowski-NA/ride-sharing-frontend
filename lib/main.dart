import 'package:blablafront/features/navigation/main_layout.dart';
import 'package:blablafront/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;
import 'package:blablafront/core/providers/auth_provider.dart';
import 'package:blablafront/core/services/api_client.dart';
import 'package:blablafront/core/network/auth_token_provider.dart';
import 'package:blablafront/routes/app_router.dart';

void main() {
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          provider.ChangeNotifierProvider(create: (_) => AuthProvider()..initialize()),
          provider.Provider(create: (_) => ApiClient()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _tokenInitialized = false;

  @override
  void initState() {
    super.initState();
    // Sync token from storage to Riverpod on app startup
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final container = ProviderScope.containerOf(context);
      await initializeAuthToken(container);
      if (mounted) {
        setState(() => _tokenInitialized = true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Connect ApiClient token expiration to AuthProvider
    final apiClient = provider.Provider.of<ApiClient>(context, listen: false);
    final authProvider = provider.Provider.of<AuthProvider>(context, listen: false);
    apiClient.onTokenExpired = () => authProvider.handleTokenExpiration();

    return MaterialApp(
      title: 'Vamos Ride Sharing',
      theme: AppTheme.lightTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: const MainLayout(),
    );
  }
}
