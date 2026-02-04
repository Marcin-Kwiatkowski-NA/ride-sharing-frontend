import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:blablafront/core/providers/auth_notifier.dart';
import 'package:blablafront/core/providers/auth_state.dart';
import 'package:blablafront/routes/app_router.dart';

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
        AppRouter.navigateAndClearStack(context, AppRoutes.profile);
      }
      // Show error message if present
      if (next.errorMessage != null && next.errorMessage != previous?.errorMessage) {
        _showError(next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
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
              decoration: const InputDecoration(
                labelText: 'Display Name',
                prefixIcon: Icon(Icons.person),
                helperText: 'This is the name other users will see.',
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Enter a display name';
                }
                if (text.length < 2) {
                  return 'Display name must be at least 2 characters';
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
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Enter your email';
                }
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(text)) {
                  return 'Enter a valid email';
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
              decoration: const InputDecoration(
                labelText: 'Password',
                prefixIcon: Icon(Icons.lock),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Enter a password';
                }
                if (text.length < 6) {
                  return 'Password must be at least 6 characters';
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
              decoration: const InputDecoration(
                labelText: 'Confirm Password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
              validator: (text) {
                if (text == null || text.isEmpty) {
                  return 'Confirm your password';
                }
                if (text != _passwordController.text) {
                  return 'Passwords do not match';
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
                    : const Text('Create Account'),
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
                    'OR',
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
                label: const Text('Continue with Google'),
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
                const Text('Already have an account? '),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Login'),
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
      const SnackBar(
        content: Text('Google sign-up coming soon!'),
        duration: Duration(seconds: 2),
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
