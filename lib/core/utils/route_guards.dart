import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:blablafront/core/providers/auth_provider.dart';
import 'package:blablafront/views/LoginScreen.dart';

/// Widget that protects routes from unauthenticated access
///
/// Wraps a child widget and checks authentication status.
/// Redirects to LoginScreen if user is not authenticated.
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Show loading while checking auth status
        if (authProvider.status == AuthStatus.uninitialized) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Redirect to login if not authenticated
        if (!authProvider.isAuthenticated) {
          // Use addPostFrameCallback to avoid build-time navigation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginScreen()),
              (route) => false,
            );
          });

          // Show loading while redirecting
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // User is authenticated, show the protected content
        return child;
      },
    );
  }
}
