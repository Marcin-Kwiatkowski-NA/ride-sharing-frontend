import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/l10n_extension.dart';
import '../../../../core/providers/auth_notifier.dart';
import '../../../../core/widgets/page_layout.dart';
import '../../../../routes/routes.dart';

class VerifyResultScreen extends ConsumerStatefulWidget {
  final String? status;

  const VerifyResultScreen({super.key, this.status});

  @override
  ConsumerState<VerifyResultScreen> createState() => _VerifyResultScreenState();
}

class _VerifyResultScreenState extends ConsumerState<VerifyResultScreen> {
  bool _resending = false;

  bool get _isSuccess => widget.status == 'success';

  @override
  void initState() {
    super.initState();
    if (_isSuccess) {
      // Refresh user profile to update isEmailVerified
      final auth = ref.read(authProvider);
      if (auth.isAuthenticated) {
        ref.read(authProvider.notifier).refreshUser();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final isAuthenticated = ref.watch(authProvider).isAuthenticated;

    return Scaffold(
      body: PageLayout.form(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Icon(
                  _isSuccess ? Icons.check_circle_outline : Icons.warning_amber_rounded,
                  size: 80,
                  color: _isSuccess
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
                const SizedBox(height: 24),
                Text(
                  _isSuccess ? l10n.emailVerifiedSuccess : l10n.emailVerificationFailed,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _buildSubtitle(context, isAuthenticated),
                const SizedBox(height: 32),
              ..._buildActions(context, isAuthenticated),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context, bool isAuthenticated) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    final String message;
    if (_isSuccess) {
      message = isAuthenticated ? '' : l10n.emailVerifiedSignIn;
    } else {
      message = isAuthenticated ? '' : l10n.requestNewVerification;
    }

    if (message.isEmpty) return const SizedBox.shrink();

    return Text(
      message,
      style: theme.textTheme.bodyLarge?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
      textAlign: TextAlign.center,
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isAuthenticated) {
    final l10n = context.l10n;

    if (_isSuccess) {
      if (isAuthenticated) {
        return [
          FilledButton(
            onPressed: () => context.go(RoutePaths.rides),
            child: Text(l10n.continueToApp),
          ),
        ];
      } else {
        return [
          FilledButton(
            onPressed: () => context.go(RoutePaths.login),
            child: Text(l10n.goToLogin),
          ),
        ];
      }
    }

    // Error state
    if (isAuthenticated) {
      return [
        FilledButton(
          onPressed: _resending ? null : _handleResend,
          child: _resending
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l10n.resendVerificationEmail),
        ),
      ];
    } else {
      return [
        FilledButton(
          onPressed: () => context.go(RoutePaths.login),
          child: Text(l10n.goToLogin),
        ),
      ];
    }
  }

  Future<void> _handleResend() async {
    setState(() => _resending = true);
    final result = await ref.read(authProvider.notifier).resendVerification();
    if (!mounted) return;
    setState(() => _resending = false);

    final l10n = context.l10n;
    final message = switch (result) {
      ResendSuccess() => l10n.verificationEmailSent,
      ResendAlreadyVerified() => l10n.emailAlreadyVerified,
      ResendCooldown(:final seconds) => l10n.verificationCooldown(seconds),
      ResendError() => l10n.genericVerificationError,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
