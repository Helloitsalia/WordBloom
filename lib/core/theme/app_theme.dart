import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  // Default Sage theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,

      scaffoldBackgroundColor: AppColors.sageBackground,

      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.sagePrimary,
        primary: AppColors.sagePrimary,
        onPrimary: Colors.white,
        surface: AppColors.sageBackground,
        onSurface: AppColors.sageDark,
      ),

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.sageBackground,
        foregroundColor: AppColors.sageDark,
        centerTitle: true,
        elevation: 0,
      ),

      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.sagePrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.sagePrimary,
        foregroundColor: Colors.white,
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.sagePrimary,
      ),
    );
  }
}
