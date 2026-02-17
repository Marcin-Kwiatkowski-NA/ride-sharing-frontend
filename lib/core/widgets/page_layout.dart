import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/layout_tokens.dart';

/// Page category presets controlling max-width and extra horizontal padding.
enum PagePreset {
  /// Forms: 560px max, extra 24px form padding on top of gutters.
  form(maxWidth: ContentWidth.form, extraHorizontalPadding: 24),

  /// Lists, details, profiles: 840px max, gutters only.
  content(maxWidth: ContentWidth.content, extraHorizontalPadding: 0),

  /// Chat threads: 720px max, gutters only.
  chat(maxWidth: ContentWidth.chat, extraHorizontalPadding: 0);

  const PagePreset({required this.maxWidth, required this.extraHorizontalPadding});
  final double maxWidth;
  final double extraHorizontalPadding;
}

/// Computes horizontal gutters for medium+ only.
///
/// On compact, returns zero gutters (screens already have their own padding).
/// On medium+, applies M3 spacing + [extraWide] so web/tablet gets consistent
/// readability margins without double-padding existing mobile layouts.
EdgeInsets _pageGutters(
  BuildContext context,
  WindowWidthClass sizeClass, {
  required double extraWide,
}) {
  final vp = MediaQuery.viewPaddingOf(context);

  final base = sizeClass >= WindowWidthClass.medium ? sizeClass.spacing : 0.0;
  final extra = sizeClass >= WindowWidthClass.medium ? extraWide : 0.0;

  return EdgeInsets.only(
    left: math.max(base, vp.left) + extra,
    right: math.max(base, vp.right) + extra,
  );
}

/// Responsive page wrapper that constrains content to a max width,
/// centers it at the top, and applies size-class-aware gutters.
///
/// Uses [LayoutBuilder] + [WindowWidthClass.fromWidth] so it responds
/// to actual available width (after navigation rail consumes space).
class PageLayout extends StatelessWidget {
  final PagePreset preset;
  final bool safeArea;
  final Widget child;

  const PageLayout({
    super.key,
    this.preset = PagePreset.content,
    this.safeArea = false,
    required this.child,
  });

  const PageLayout.form({super.key, this.safeArea = false, required this.child})
      : preset = PagePreset.form;

  const PageLayout.chat({super.key, this.safeArea = false, required this.child})
      : preset = PagePreset.chat;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final sizeClass = WindowWidthClass.fromWidth(constraints.maxWidth);
      final gutters = _pageGutters(context, sizeClass, extraWide: preset.extraHorizontalPadding);
      final needsConstraint = constraints.maxWidth > preset.maxWidth;

      Widget result = child;
      if (safeArea) result = SafeArea(child: result);
      result = Padding(padding: gutters, child: result);

      if (!needsConstraint) return result;

      return Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: preset.maxWidth),
          child: result,
        ),
      );
    });
  }
}

/// Constrained bottom area that aligns with page content width
/// and respects system view padding + keyboard insets.
class PageBottomArea extends StatelessWidget {
  final PagePreset preset;
  final Widget child;

  const PageBottomArea({
    super.key,
    this.preset = PagePreset.form,
    required this.child,
  });

  const PageBottomArea.content({super.key, required this.child})
      : preset = PagePreset.content;

  @override
  Widget build(BuildContext context) {
    final vp = MediaQuery.viewPaddingOf(context);
    final vi = MediaQuery.viewInsetsOf(context);
    final sg = MediaQuery.systemGestureInsetsOf(context);

    return LayoutBuilder(builder: (context, constraints) {
      final sizeClass = WindowWidthClass.fromWidth(constraints.maxWidth);
      final gutters = _pageGutters(context, sizeClass, extraWide: preset.extraHorizontalPadding);
      final bottomPad = math.max(vi.bottom, math.max(vp.bottom, sg.bottom));
      final padding = gutters.copyWith(top: 12, bottom: bottomPad + 12);

      final needsConstraint = constraints.maxWidth > preset.maxWidth;
      final content = Padding(padding: padding, child: child);

      if (!needsConstraint) {
        // shrink-wrap height so bottomNavigationBar slot doesn't steal body space
        return Center(heightFactor: 1.0, child: content);
      }

      return Center(
        heightFactor: 1.0,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: preset.maxWidth),
          child: content,
        ),
      );
    });
  }
}
