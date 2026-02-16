import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Centralized M3 design system for the Vamos app.
///
/// Produces light and dark [ThemeData] from a single teal seed.
/// All surfaces, colors, and component styles derive from [ColorScheme.fromSeed].
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────
  // Brand Colors (seed inputs only — never used directly in UI code)
  // ─────────────────────────────────────────────────────────────────────────────
  static const Color _seedColor = Color(0xFF009688); // Teal 500
  static const Color _tertiaryColor = Color(0xFFFFC107); // Amber — brand CTA
  static const Color _errorColor = Color(0xFFBA1A1A); // M3 standard

  // ─────────────────────────────────────────────────────────────────────────────
  // Public Theme Getters
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => _buildTheme(Brightness.light);
  static ThemeData get darkTheme => _buildTheme(Brightness.dark);

  // ─────────────────────────────────────────────────────────────────────────────
  // Theme Builder
  // ─────────────────────────────────────────────────────────────────────────────
  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _seedColor,
      tertiary: _tertiaryColor,
      error: _errorColor,
      brightness: brightness,
    );

    final tokens = AppTokens.fromScheme(colorScheme);
    final defaultRadius = BorderRadius.circular(AppTokens.radiusMD);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surfaceContainerLowest,
      extensions: [tokens],

      // ─────────────────────────────────────────────────────────────────────────
      // Typography: Poppins headings, Roboto body
      // No hardcoded colors — ThemeData resolves from ColorScheme.
      // ─────────────────────────────────────────────────────────────────────────
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge:
            GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: -1.0),
        displayMedium:
            GoogleFonts.poppins(fontWeight: FontWeight.w700, letterSpacing: -0.5),
        displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        titleMedium: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.roboto(fontSize: 16, height: 1.5),
        bodyMedium: GoogleFonts.roboto(fontSize: 14, height: 1.5),
        labelLarge: GoogleFonts.roboto(fontWeight: FontWeight.w600),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // AppBar: surface-based (M3 default)
      // ─────────────────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: AppTokens.elevationMid,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
          letterSpacing: 0.5,
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Input Decoration: filled, tonal surface, state-aware icon colors
      // ─────────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surfaceContainerLow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        hintStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w400,
        ),
        prefixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        suffixIconColor: WidgetStateColor.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return colorScheme.onSurface.withValues(alpha: 0.38);
          }
          if (states.contains(WidgetState.focused)) {
            return colorScheme.primary;
          }
          return colorScheme.onSurfaceVariant;
        }),
        enabledBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide:
              BorderSide(color: colorScheme.outlineVariant, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: defaultRadius,
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Search Bar: pill shape, calm surface, for search-like surfaces
      // Must NOT share InputDecorationTheme visuals.
      // ─────────────────────────────────────────────────────────────────────────
      searchBarTheme: SearchBarThemeData(
        elevation: WidgetStatePropertyAll(AppTokens.elevationHigh),
        shape: const WidgetStatePropertyAll(StadiumBorder()),
        backgroundColor:
            WidgetStatePropertyAll(colorScheme.surfaceContainerHigh),
        hintStyle: WidgetStatePropertyAll(TextStyle(
          color: colorScheme.onSurfaceVariant,
        )),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Button Themes
      // ─────────────────────────────────────────────────────────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: AppTokens.elevationLow,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
          textStyle:
              GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: defaultRadius),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Segmented Button
      // ─────────────────────────────────────────────────────────────────────────
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.primary;
            }
            return colorScheme.surfaceContainerLow;
          }),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return colorScheme.onPrimary;
            }
            return colorScheme.onSurface;
          }),
          side: WidgetStatePropertyAll(
            BorderSide(color: colorScheme.outlineVariant),
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Navigation Bar
      // ─────────────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colorScheme.surface,
        height: 75,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: colorScheme.primary);
          }
          return IconThemeData(color: colorScheme.onSurfaceVariant);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: colorScheme.onSurfaceVariant,
          );
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Bottom Sheet
      // ─────────────────────────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colorScheme.surfaceContainer,
        modalBarrierColor: tokens.overlayScrim,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusXL),
          ),
        ),
        showDragHandle: true,
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Card Theme
      // ─────────────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        elevation: AppTokens.elevationNone,
        shape: RoundedRectangleBorder(
          borderRadius: defaultRadius,
          side: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        clipBehavior: Clip.antiAlias,
      ),

// ─────────────────────────────────────────────────────────────────────────
// Chip Theme (theme-driven, readable in M3)
// ─────────────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        brightness: brightness,

        // Unselected chip background + border
        backgroundColor: colorScheme.surfaceContainerHighest,
        side: BorderSide(color: colorScheme.outlineVariant),
        shape: const StadiumBorder(),

        // Selected background for ChoiceChip specifically
        // (ChoiceChip reads secondarySelectedColor) [web:61]
        secondarySelectedColor: colorScheme.primaryContainer,

        // Keep selectedColor too (covers other chip types / older behaviors)
        selectedColor: colorScheme.primaryContainer,

        // Text: unselected vs selected (ChoiceChip uses secondaryLabelStyle when selected) [web:61]
        labelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
        secondaryLabelStyle: GoogleFonts.roboto(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: colorScheme.onPrimaryContainer,
        ),

        // Icons (affects avatar/delete/checkmark where applicable)
        iconTheme: IconThemeData(
          size: 18,
          color: colorScheme.onSurface,
        ),

        // Spacing / behavior
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        showCheckmark: false,
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Divider Theme
      // ─────────────────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: colorScheme.outlineVariant,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
