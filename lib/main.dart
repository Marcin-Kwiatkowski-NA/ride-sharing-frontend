import 'package:blablafront/views/Search_Ride_Screen.dart';
import 'package:blablafront/views/LoginScreen.dart';
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
      theme: blablatwoTheme,
      onGenerateRoute: AppRouter.generateRoute,
      home: provider.Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show loading screen while checking auth status
          if (authProvider.status == AuthStatus.uninitialized) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          // Navigate based on authentication status
          return authProvider.isAuthenticated
              ? const SearchRideScreen()
              : const LoginScreen();
        },
      ),
    );
  }
}

final ThemeData blablatwoTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.teal,
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.teal,
    elevation: 10,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Roboto', // Ensure this font is available or replace it.
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      foregroundColor: Colors.black87,
      disabledBackgroundColor: Colors.teal.shade100,
      backgroundColor: Colors.teal,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      textStyle: TextStyle(
        fontFamily: 'Roboto', // Ensure this font is available or replace it.
        fontSize: 20,
        fontWeight: FontWeight.normal,
      ),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.teal, // Primary color for FAB
    foregroundColor: Colors.white, // Icon/text color for FAB
    elevation: 6.0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)), // Standard FAB shape
  ),
);