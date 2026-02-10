import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/providers/auth_state.dart';
import '../../../../routes/routes.dart';

class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    // Listen for auth state changes to handle navigation and errors
    ref.listen<AuthState>(authProvider, (previous, next) {
      // Navigate to profile on successful authentication
      if (next.status == AuthStatus.authenticated) {
        context.goNamed(RouteNames.profile);
      }
      // Show error message if present
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showError(next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.createAccountTitle)),
      body: Center(child: _buildForm()),
    );
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Display Name field
            TextFormField(
              controller: _displayNameController,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: context.l10n.displayNameLabel,
                prefixIcon: const Icon(Icons.person),
                helperText: context.l10n.displayNameHelper,
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return context.l10n.enterDisplayName;
                }
                if (text.length < 2) {
                  return context.l10n.displayNameMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

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
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return context.l10n.enterAPassword;
                }
                if (text.length < 6) {
                  return context.l10n.passwordMinLength;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password field
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: true,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: InputDecoration(
                labelText: context.l10n.confirmPasswordLabel,
                prefixIcon: const Icon(Icons.lock_outline),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return context.l10n.confirmPassword;
                }
                if (text != _passwordController.text) {
                  return context.l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Create Account button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleRegister,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(context.l10n.createAccountTitle),
              ),
            ),
            const SizedBox(height: 30),

            // Divider with "OR"
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey.shade400)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    context.l10n.or,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                Expanded(child: Divider(color: Colors.grey.shade400)),
              ],
            ),
            const SizedBox(height: 30),

            // Google Sign-In placeholder button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _isLoading ? null : _handleGoogleSignUp,
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
                  side: BorderSide(color: Colors.grey.shade400),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Login link
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(context.l10n.alreadyHaveAccount),
                TextButton(
                  onPressed: () {
                    context.pop();
                  },
                  child: Text(context.l10n.loginTitle),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    final form = _formKey.currentState;
    if (form?.validate() == false) {
      return;
    }

    setState(() => _isLoading = true);

    await ref.read(authProvider.notifier).register(
      _emailController.text,
      _passwordController.text,
      _displayNameController.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _handleGoogleSignUp() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.googleSignUpComingSoon),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}
