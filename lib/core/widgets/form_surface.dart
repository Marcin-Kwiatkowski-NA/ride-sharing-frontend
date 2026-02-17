import 'package:flutter/material.dart';

import '../theme/layout_tokens.dart';

/// On medium+ widths, wraps its child in a Card with surfaceContainerLow
/// background. On compact widths, passes through unchanged.
///
/// Uses [LayoutBuilder] + [WindowWidthClass.fromWidth] for parent-constraint
/// awareness (responds to actual available width after rail consumes space).
class FormSurface extends StatelessWidget {
  final Widget child;

  const FormSurface({super.key, required this.child});

  static const _cardMargin = EdgeInsets.symmetric(vertical: 24);
  static const _cardPadding = EdgeInsets.symmetric(horizontal: 32, vertical: 24);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (WindowWidthClass.fromWidth(constraints.maxWidth) < WindowWidthClass.medium) {
        return child;
      }
      return Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        margin: _cardMargin,
        child: Padding(padding: _cardPadding, child: child),
      );
    });
  }
}
