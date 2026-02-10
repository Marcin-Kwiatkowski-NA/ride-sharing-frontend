import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/l10n/l10n_extension.dart';
import 'routes.dart';

class ErrorScreen extends StatelessWidget {
  final GoException? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.errorTitle)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(context.l10n.pageNotFound, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                error?.message ?? context.l10n.pageNotFoundMessage,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.goNamed(RouteNames.rides),
                icon: const Icon(Icons.home),
                label: Text(context.l10n.goHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
