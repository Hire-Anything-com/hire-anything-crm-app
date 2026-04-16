import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralized typography for the application using Material 3 standards.
/// This allows for easy `copyWith` modifications within the UI.
class AppTypography {
  AppTypography._();

  /// Base text style using Poppins for clean readability.
  static final TextStyle _baseTextStyle = GoogleFonts.poppins();

  /// Large display style for hero elements.
  static final TextStyle displayLarge = _baseTextStyle.copyWith(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    height: 1.12,
  );

  /// Medium display style.
  static final TextStyle displayMedium = _baseTextStyle.copyWith(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.16,
  );

  /// Small display style.
  static final TextStyle displaySmall = _baseTextStyle.copyWith(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    height: 1.22,
  );

  /// Large headline style for screen titles.
  static final TextStyle headlineLarge = _baseTextStyle.copyWith(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    letterSpacing: 0,
    height: 1.25,
  );

  /// Medium headline style.
  static final TextStyle headlineMedium = _baseTextStyle.copyWith(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.29,
  );

  /// Small headline style.
  static final TextStyle headlineSmall = _baseTextStyle.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    height: 1.33,
  );

  /// Large title style.
  static final TextStyle titleLarge = _baseTextStyle.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
    height: 1.27,
  );

  /// Medium title style for section headers.
  static final TextStyle titleMedium = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.15,
    height: 1.5,
  );

  /// Small title style.
  static final TextStyle titleSmall = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Large body text for primary content.
  static final TextStyle bodyLarge = _baseTextStyle.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    height: 1.5,
  );

  /// Medium body text.
  static final TextStyle bodyMedium = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    height: 1.43,
  );

  /// Small body text for supporting information.
  static final TextStyle bodySmall = _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    height: 1.33,
  );

  /// Large label style for buttons.
  static final TextStyle labelLarge = _baseTextStyle.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.1,
    height: 1.43,
  );

  /// Medium label style for small labels.
  static final TextStyle labelMedium = _baseTextStyle.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.33,
  );

  /// Small label style.
  static final TextStyle labelSmall = _baseTextStyle.copyWith(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    height: 1.45,
  );
}
