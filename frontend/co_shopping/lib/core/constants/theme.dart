import 'package:flutter/material.dart';

class AppColors {
  static const primaryGreen = Color(0xFF008966);
  static const secondaryGreen = Color(0xFFE6F4F1);
  static const background = Color(0xFFF8F9FA);
  static const cardWhite = Colors.white;
  static const textDark = Color(0xFF1A1A1A);
  static const textGrey = Color(0xFF757575);
}

final appTheme = ThemeData(
  scaffoldBackgroundColor: AppColors.background,
  fontFamily: 'Inter', // Asegúrate de agregarla en pubspec.yaml
  textTheme: const TextTheme(
    displaySmall: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.textDark,
    ),
    titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    bodyMedium: TextStyle(fontSize: 14, color: AppColors.textGrey),
  ),
);
