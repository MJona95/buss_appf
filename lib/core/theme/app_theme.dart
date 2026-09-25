import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Brand color constants
  static const Color primaryColor = Colors.black;
  static const Color onPrimaryColor = Colors.white;
  static const Color backgroundColor = Color(0xFFFAF9FE);
  static const Color onBackgroundColor = Color(0xFF1A1B1F);

  static const Color secondaryColor = Color(0xFF5D5F5F);
  static const Color cardColor = Colors.white;
  static const Color borderVariantColor = Color(0xFFCFC4C5);
  static const Color surfaceContainerLow = Color(0xFFF4F3F8);
  static const Color surfaceContainer = Color(0xFFEEEDF3);
  static const Color surfaceContainerHigh = Color(0xFFE9E7ED);

  // Dark scale
  static const Color darkBackgroundColor = Color(0xFF121212);
  static const Color darkOnBackgroundColor = Color(0xFFE4E2E6);
  static const Color darkSecondaryColor = Color(0xFFCAC8D0);
  static const Color darkCardColor = Color(0xFF1E1E1F);
  static const Color darkBorderVariantColor = Color(0xFF49454F);
  static const Color darkSurfaceContainerLow = Color(0xFF1A1A1B);
  static const Color darkSurfaceContainer = Color(0xFF232326);
  static const Color darkSurfaceContainerHigh = Color(0xFF2D2D30);

  // Border radius constants
  static const double cardRadius = 32.0;
  static const double elementRadius = 16.0;

  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        onPrimary: onPrimaryColor,
        surface: backgroundColor,
        onSurface: onBackgroundColor,
        secondary: secondaryColor,
        outline: borderVariantColor,
        outlineVariant: borderVariantColor,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.72,
          color: onBackgroundColor,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.56,
          color: onBackgroundColor,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: onBackgroundColor,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: onBackgroundColor,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: onBackgroundColor,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(
            color: Color(0x1F000000), // thin border
            width: 1.0,
          ),
        ),
      ),
    );
  }

  static ThemeData get darkThemeData {
    final baseTextTheme = GoogleFonts.plusJakartaSansTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: onPrimaryColor,
      scaffoldBackgroundColor: darkBackgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: onPrimaryColor,
        onPrimary: primaryColor,
        surface: darkBackgroundColor,
        onSurface: darkOnBackgroundColor,
        secondary: darkSecondaryColor,
        outline: darkBorderVariantColor,
        outlineVariant: darkBorderVariantColor,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.72,
          color: darkOnBackgroundColor,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.56,
          color: darkOnBackgroundColor,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: darkOnBackgroundColor,
        ),
        bodyLarge: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkOnBackgroundColor,
        ),
        bodyMedium: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: darkOnBackgroundColor,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: darkOnBackgroundColor,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(cardRadius),
          side: const BorderSide(color: Color(0x1FFFFFFF), width: 1.0),
        ),
      ),
    );
  }
}
