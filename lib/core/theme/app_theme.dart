import 'package:flutter/material.dart';
import 'package:hireanythingbooking/core/theme/app_colors.dart';
import 'package:hireanythingbooking/core/theme/app_typography.dart';

/// Application theme configuration.
class AppTheme {
  AppTheme._();

  /// Light Theme Definition
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      surface: AppColors.surface,
      error: AppColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textWhite,
        elevation: 0,
        centerTitle: true,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge,
        displayMedium: AppTypography.displayMedium,
        displaySmall: AppTypography.displaySmall,
        headlineLarge: AppTypography.headlineLarge,
        headlineMedium: AppTypography.headlineMedium,
        headlineSmall: AppTypography.headlineSmall,
        titleLarge: AppTypography.titleLarge,
        titleMedium: AppTypography.titleMedium,
        titleSmall: AppTypography.titleSmall,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
        bodySmall: AppTypography.bodySmall,
        labelLarge: AppTypography.labelLarge,
        labelMedium: AppTypography.labelMedium,
        labelSmall: AppTypography.labelSmall,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.fieldBorderFocused,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.grey300),
        ),
        hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.grey400),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.btnColor,
          foregroundColor: AppColors.textWhite,
          disabledBackgroundColor: AppColors.disabledBtnColor,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTypography.labelLarge,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        color: AppColors.surface,
        shadowColor: AppColors.shadowLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textLight,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.borderLight,
        thickness: 1,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        elevation: 4,
      ),
    );
  }

  /// Dark Theme Definition
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      textTheme: TextTheme(
        displayLarge: AppTypography.displayLarge.copyWith(
          color: AppColors.textWhite,
        ),
        displayMedium: AppTypography.displayMedium.copyWith(
          color: AppColors.textWhite,
        ),
        displaySmall: AppTypography.displaySmall.copyWith(
          color: AppColors.textWhite,
        ),
        headlineLarge: AppTypography.headlineLarge.copyWith(
          color: AppColors.textWhite,
        ),
        headlineMedium: AppTypography.headlineMedium.copyWith(
          color: AppColors.textWhite,
        ),
        headlineSmall: AppTypography.headlineSmall.copyWith(
          color: AppColors.textWhite,
        ),
        titleLarge: AppTypography.titleLarge.copyWith(
          color: AppColors.textWhite,
        ),
        titleMedium: AppTypography.titleMedium.copyWith(
          color: AppColors.textWhite,
        ),
        titleSmall: AppTypography.titleSmall.copyWith(
          color: AppColors.textWhite,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: AppColors.textWhite),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textWhite,
        ),
        bodySmall: AppTypography.bodySmall.copyWith(color: AppColors.textWhite),
        labelLarge: AppTypography.labelLarge.copyWith(
          color: AppColors.textWhite,
        ),
        labelMedium: AppTypography.labelMedium.copyWith(
          color: AppColors.textWhite,
        ),
        labelSmall: AppTypography.labelSmall.copyWith(
          color: AppColors.textWhite,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textWhite,
          textStyle: AppTypography.labelLarge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTypography.labelLarge,
        ),
      ),
    );
  }
}
