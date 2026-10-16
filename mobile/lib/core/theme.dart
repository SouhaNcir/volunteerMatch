import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF0F766E);
  static const primaryDark = Color(0xFF134E4A);
  static const accent = Color(0xFFF59E0B);
  static const background = Color(0xFFF4F7F9);
  static const text = Color(0xFF0F172A);
  static const muted = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);
  static const danger = Color(0xFFDC2626);
}

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    secondary: AppColors.accent,
  );
  final base = ThemeData(useMaterial3: true, colorScheme: scheme);

  OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: c, width: w),
  );

  final buttonShape =
  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14));
  const buttonText = TextStyle(fontSize: 16, fontWeight: FontWeight.w600);

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    textTheme: base.textTheme
        .apply(bodyColor: AppColors.text, displayColor: AppColors.text),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: border(AppColors.border),
      enabledBorder: border(AppColors.border),
      focusedBorder: border(AppColors.primary, 1.8),
      errorBorder: border(AppColors.danger),
      focusedErrorBorder: border(AppColors.danger, 1.8),
      prefixIconColor: AppColors.muted,
      labelStyle: const TextStyle(color: AppColors.muted),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: buttonShape,
        textStyle: buttonText,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(54),
        shape: buttonShape,
        side: const BorderSide(color: AppColors.border),
        textStyle: buttonText,
      ),
    ),
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: Colors.white,
      indicatorColor: Color(0xFFCCFBF1),
    ),
  );
}