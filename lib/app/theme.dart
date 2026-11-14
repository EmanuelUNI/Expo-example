import 'package:flutter/material.dart';

abstract final class AppColors {
  static const ink = Color(0xFF172B3A);
  static const muted = Color(0xFF627481);
  static const green = Color(0xFF087F64);
  static const mint = Color(0xFFE7F4EF);
  static const canvas = Color(0xFFF4F6F8);
  static const line = Color(0xFFE3E9ED);
}

ThemeData buildTheme() => ThemeData(
  useMaterial3: true,
  scaffoldBackgroundColor: AppColors.canvas,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    onPrimary: Colors.white,
    surface: Colors.white,
    onSurface: AppColors.ink,
  ),
  textTheme: const TextTheme(
    headlineLarge: TextStyle(
      fontSize: 40,
      height: 1.12,
      fontWeight: FontWeight.w800,
      letterSpacing: -1.5,
    ),
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.5,
    ),
    titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    bodyLarge: TextStyle(fontSize: 16, height: 1.5),
    bodyMedium: TextStyle(fontSize: 14, height: 1.5),
    bodySmall: TextStyle(fontSize: 12, height: 1.5, color: AppColors.muted),
  ).apply(bodyColor: AppColors.ink, displayColor: AppColors.ink),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      minimumSize: const Size(48, 56),
      textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(48, 56),
      side: const BorderSide(color: AppColors.line),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
  ),
  dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1),
);
