import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized "Ocean" design system theme for the Vamos app
class AppTheme {
  // Private constructor to prevent instantiation
  AppTheme._();

  // ─────────────────────────────────────────────────────────────────────────────
  // Color Palette
  // ─────────────────────────────────────────────────────────────────────────────

  static const Color _primaryColor = Color(0xFF009688); // Teal 500
  static const Color _secondaryColor = Color(0xFFFFC107); // Amber 500
  static const Color _surfaceColor = Colors.white;
  static const Color _backgroundColor = Color(0xFFF5F7FA);
  static const Color _errorColor = Color(0xFFD32F2F);

  // ─────────────────────────────────────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────────────────────────────────────

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: _primaryColor,
      brightness: Brightness.light,
      primary: _primaryColor,
      secondary: _secondaryColor,
      surface: _surfaceColor,
      error: _errorColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _backgroundColor,

      // ─────────────────────────────────────────────────────────────────────────
      // Typography
      // ─────────────────────────────────────────────────────────────────────────
      textTheme: GoogleFonts.robotoTextTheme().copyWith(
        displayLarge: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        displayMedium: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        displaySmall: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        headlineLarge: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        headlineMedium: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        headlineSmall: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        titleLarge: GoogleFonts.poppins(fontWeight: FontWeight.w500),
        titleMedium: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        titleSmall: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        bodyLarge: GoogleFonts.roboto(),
        bodyMedium: GoogleFonts.roboto(),
        bodySmall: GoogleFonts.roboto(),
        labelLarge: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        labelMedium: GoogleFonts.roboto(fontWeight: FontWeight.w500),
        labelSmall: GoogleFonts.roboto(),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // AppBar Theme
      // ─────────────────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
        titleTextStyle: GoogleFonts.poppins(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Input Decoration Theme
      // ─────────────────────────────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorColor),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorColor, width: 2),
        ),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: TextStyle(color: Colors.grey.shade400),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Elevated Button Theme
      // ─────────────────────────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.teal.shade100,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Outlined Button Theme
      // ─────────────────────────────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          side: const BorderSide(color: _primaryColor),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: GoogleFonts.roboto(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Text Button Theme
      // ─────────────────────────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryColor,
          textStyle: GoogleFonts.roboto(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Floating Action Button Theme
      // ─────────────────────────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Navigation Bar Theme (Material 3)
      // ─────────────────────────────────────────────────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceColor,
        elevation: 3,
        height: 70,
        indicatorColor: _primaryColor.withOpacity(0.15),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.roboto(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _primaryColor,
            );
          }
          return GoogleFonts.roboto(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: _primaryColor, size: 26);
          }
          return IconThemeData(color: Colors.grey.shade600, size: 24);
        }),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Card Theme
      // ─────────────────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: _surfaceColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Divider Theme
      // ─────────────────────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
        space: 24,
      ),

      // ─────────────────────────────────────────────────────────────────────────
      // Chip Theme
      // ─────────────────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: Colors.grey.shade100,
        selectedColor: _primaryColor.withOpacity(0.2),
        labelStyle: GoogleFonts.roboto(fontSize: 13),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
