import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_radius.dart';
import 'app_borders.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return _baseTheme(
      brightness: Brightness.light,
      bg: AppColors.bgLight,
      surface: AppColors.surfaceLight,
      textPrimary: AppColors.textPrimaryLight,
      textSecondary: AppColors.textSecondaryLight,
      border: AppColors.borderLight,
      primaryBtn: AppColors.black,
      primaryBtnText: AppColors.white,
    );
  }

  static ThemeData get darkTheme {
    return _baseTheme(
      brightness: Brightness.dark,
      bg: AppColors.bgDark,
      surface: AppColors.surfaceDark,
      textPrimary: AppColors.textPrimaryDark,
      textSecondary: AppColors.textSecondaryDark,
      border: AppColors.borderDark,
      primaryBtn: AppColors.white,
      primaryBtnText: AppColors.black,
    );
  }

  static ThemeData _baseTheme({
    required Brightness brightness,
    required Color bg,
    required Color surface,
    required Color textPrimary,
    required Color textSecondary,
    required Color border,
    required Color primaryBtn,
    required Color primaryBtnText,
  }) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryBtn,
        onPrimary: primaryBtnText,
        secondary: textSecondary,
        onSecondary: bg,
        error: textPrimary,
        onError: bg,
        surface: surface,
        onSurface: textPrimary,
      ),
      textTheme: TextTheme(
        displayLarge: AppTypography.display.copyWith(color: textPrimary),
        headlineLarge: AppTypography.h1.copyWith(color: textPrimary),
        headlineMedium: AppTypography.h2.copyWith(color: textPrimary),
        headlineSmall: AppTypography.h3.copyWith(color: textPrimary),
        titleLarge: AppTypography.h4.copyWith(color: textPrimary),
        bodyLarge: AppTypography.bodyLarge.copyWith(color: textPrimary),
        bodyMedium: AppTypography.body.copyWith(color: textPrimary),
        bodySmall: AppTypography.bodySmall.copyWith(color: textSecondary),
        labelLarge: AppTypography.overline.copyWith(color: textSecondary),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: AppTypography.h3.copyWith(color: textPrimary),
        shape:
            Border(bottom: BorderSide(color: border, width: AppBorders.thin)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBtn,
          foregroundColor: primaryBtnText,
          elevation: 0,
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: border, width: AppBorders.thin),
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size(0, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.xs),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          textStyle: AppTypography.body.copyWith(fontWeight: FontWeight.w500),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.elevatedSurfaceDark : AppColors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide(color: border, width: AppBorders.thin),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide(color: border, width: AppBorders.thin),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide(color: textPrimary, width: AppBorders.focus),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xs),
          borderSide: BorderSide(color: textPrimary, width: AppBorders.strong),
        ),
        labelStyle: AppTypography.body.copyWith(color: textSecondary),
        hintStyle: AppTypography.body.copyWith(
          color: textSecondary.withOpacity(0.5),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: border,
        thickness: AppBorders.thin,
        space: 1,
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          side: BorderSide(color: border),
        ),
        margin: EdgeInsets.zero,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: border),
        ),
        titleTextStyle: AppTypography.h3.copyWith(color: textPrimary),
        contentTextStyle: AppTypography.body.copyWith(color: textPrimary),
      ),
    );
  }
}
