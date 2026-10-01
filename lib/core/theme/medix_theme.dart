import 'package:flutter/material.dart';

abstract final class MedixColors {
  static const background = Color(0xFF071423);
  static const surface = Color(0xFF0D1D31);
  static const surfaceElevated = Color(0xFF122841);
  static const primary = Color(0xFF168DFF);
  static const cyan = Color(0xFF14D8EA);
  static const success = Color(0xFF21C985);
  static const warning = Color(0xFFFFB020);
  static const danger = Color(0xFFFF5364);
  static const textPrimary = Color(0xFFF7FAFF);
  static const textSecondary = Color(0xFF9AAFC7);
}

abstract final class MedixTheme {
  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: MedixColors.primary,
      brightness: Brightness.dark,
      surface: MedixColors.surface,
      error: MedixColors.danger,
    );

    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: MedixColors.background,
      cardColor: MedixColors.surface,
      appBarTheme: const AppBarTheme(
        backgroundColor: MedixColors.background,
        foregroundColor: MedixColors.textPrimary,
        elevation: 0,
        centerTitle: false,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: MedixColors.surface,
        indicatorColor: Color(0x33168DFF),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MedixColors.surface,
        hintStyle: const TextStyle(color: MedixColors.textSecondary),
        prefixIconColor: MedixColors.textSecondary,
        suffixIconColor: MedixColors.textSecondary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF173C61)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(
            color: MedixColors.primary,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}
