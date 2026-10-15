
import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.warmCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.berry,
        primary: AppColors.berry,
        surface: AppColors.warmCream,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.warmCream,
        foregroundColor: AppColors.darkPlum,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
