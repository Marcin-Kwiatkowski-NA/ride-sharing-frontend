import 'dart:ui';

import 'package:flutter/material.dart';

/// Design tokens for the Vamos app, registered as a [ThemeExtension].
///
/// Built from a [ColorScheme] inside [AppTheme._buildTheme] so overlay recipe
/// tokens automatically adapt between light and dark mode.
///
/// Access: `Theme.of(context).extension<AppTokens>()!`
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.overlayScrim,
    required this.overlayBorder,
    required this.overlayBlurSigma,
    required this.overlayDragHandle,
    required this.brandCtaStyle,
  });

  /// Constructs tokens derived from the given [colorScheme].
  factory AppTokens.fromScheme(ColorScheme colorScheme) {
    return AppTokens(
      overlayScrim: colorScheme.scrim.withValues(alpha: 0.32),
      overlayBorder: colorScheme.onSurface.withValues(alpha: 0.1),
      overlayBlurSigma: 12.0,
      overlayDragHandle: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
      brandCtaStyle: FilledButton.styleFrom(
        backgroundColor: colorScheme.tertiary,
        foregroundColor: colorScheme.onTertiary,
        shape: const StadiumBorder(),
      ),
    );
  }

  // ── Radius tokens ──────────────────────────────────────────────────────────

  static const double radiusXS = 4;
  static const double radiusSM = 8;
  static const double radiusMD = 12;
  static const double radiusLG = 16;
  static const double radiusXL = 28;

  // ── Elevation tokens ───────────────────────────────────────────────────────

  static const double elevationNone = 0;
  static const double elevationLow = 1;
  static const double elevationMid = 2;
  static const double elevationHigh = 6;

  // ── Overlay recipe (derived from ColorScheme) ─────────────────────────────

  /// Sheet backdrop / shadow color — `scrim` at 32% opacity.
  final Color overlayScrim;

  /// Subtle container border — `onSurface` at 10% opacity.
  final Color overlayBorder;

  /// Backdrop blur radius for glassmorphism effects.
  final double overlayBlurSigma;

  /// Drag handle indicator color — `onSurfaceVariant` at 40% opacity.
  final Color overlayDragHandle;

  // ── Brand CTA button style ─────────────────────────────────────────────────

  /// Button style for the amber "Post" brand CTA.
  /// Usage: `FilledButton(style: tokens.brandCtaStyle, ...)`
  final ButtonStyle brandCtaStyle;

  // ── ThemeExtension contract ────────────────────────────────────────────────

  @override
  AppTokens copyWith({
    Color? overlayScrim,
    Color? overlayBorder,
    double? overlayBlurSigma,
    Color? overlayDragHandle,
    ButtonStyle? brandCtaStyle,
  }) {
    return AppTokens(
      overlayScrim: overlayScrim ?? this.overlayScrim,
      overlayBorder: overlayBorder ?? this.overlayBorder,
      overlayBlurSigma: overlayBlurSigma ?? this.overlayBlurSigma,
      overlayDragHandle: overlayDragHandle ?? this.overlayDragHandle,
      brandCtaStyle: brandCtaStyle ?? this.brandCtaStyle,
    );
  }

  @override
  AppTokens lerp(covariant AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      overlayScrim: Color.lerp(overlayScrim, other.overlayScrim, t)!,
      overlayBorder: Color.lerp(overlayBorder, other.overlayBorder, t)!,
      overlayBlurSigma:
          lerpDouble(overlayBlurSigma, other.overlayBlurSigma, t)!,
      overlayDragHandle:
          Color.lerp(overlayDragHandle, other.overlayDragHandle, t)!,
      brandCtaStyle:
          ButtonStyle.lerp(brandCtaStyle, other.brandCtaStyle, t) ??
              brandCtaStyle,
    );
  }
}
