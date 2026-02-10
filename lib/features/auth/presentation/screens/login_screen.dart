import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/providers/auth_state.dart';
import '../../../../routes/routes.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final String? returnTo;
  final String? backTo;

  const LoginScreen({super.key, this.returnTo, this.backTo});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to handle navigation and errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Navigate on successful authentication
      if (next.status == AuthStatus.authenticated) {
        // Validate returnTo to prevent open redirects - must be internal path
        final returnTo = widget.returnTo;
        if (returnTo != null && returnTo.startsWith('/')) {
          context.go(returnTo);
        } else {
          context.goNamed(RouteNames.rides);
        }
      }
      // Show error message if present
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showError(next.errorMessage!);
      }
    });

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(context.l10n.loginTitle),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: Center(child: _buildLoginForm()),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Email field
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: context.l10n.emailLabel,
                prefixIcon: const Icon(Icons.email),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return context.l10n.enterEmail;
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
                  return context.l10n.enterValidEmail;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Password field
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: context.l10n.passwordLabel,
                prefixIcon: const Icon(Icons.lock),
              ),
              validator: (text) =>
                  text!.isEmpty ? context.l10n.enterPassword : null,
            ),
            const SizedBox(height: 24),

            // Login button
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isLoading ? null : _handleLogin,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.loginTitle),
              ),
            ),
            const SizedBox(height: 30),

            // Divider with "OR"
            Row(
              children: [
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.or,
                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                  ),
                ),
                Expanded(child: Divider(color: Theme.of(context).colorScheme.outlineVariant)),
              ],
            ),
            const SizedBox(height: 30),

            // Google Sign-In button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignIn,
                icon: Image.asset(
                  'assets/google_logo.png',
                  height: 24,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.g_mobiledata, size: 24);
                  },
                ),
                label: Text(context.l10n.continueWithGoogle),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  side: BorderSide(color: Theme.of(context).colorScheme.outline),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Sign up link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.dontHaveAccount),
                TextButton(
                  onPressed: () {
                    context.pushNamed(RouteNames.createAccount);
                  },
                  child: Text(context.l10n.signUp),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleLogin() async {
    final form = _formKey.currentState;
    if (form?.validate() == false) {
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).signInWithEmail(
      _emailController.text,
      _passwordController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).signInWithGoogle();

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }

  void _handleBack() {
    // canPop has quirks with shell routes - fallback to backTo is the reliable path
    if (GoRouter.of(context).canPop()) {
      context.pop();
    } else {
      context.go(widget.backTo ?? '/rides');
    }
  }
}
