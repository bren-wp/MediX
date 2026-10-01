import 'package:flutter/material.dart';

abstract final class MedixColors {
  static const background = Color(0xFF020B14);
  static const backgroundAlt = Color(0xFF041522);
  static const surface = Color(0xFF071C2D);
  static const surfaceElevated = Color(0xFF0A2941);
  static const surfaceBright = Color(0xFF0E3554);
  static const border = Color(0xFF0E4D75);
  static const borderSoft = Color(0xFF0A3858);
  static const primary = Color(0xFF139BFF);
  static const primaryStrong = Color(0xFF047BFF);
  static const cyan = Color(0xFF20D7FF);
  static const cyanSoft = Color(0xFF86E8FF);
  static const success = Color(0xFF2BD978);
  static const warning = Color(0xFFFFB83D);
  static const danger = Color(0xFFFF5864);
  static const purple = Color(0xFF9A6CFF);
  static const textPrimary = Color(0xFFF7FBFF);
  static const textSecondary = Color(0xFFA5BDD0);
  static const textMuted = Color(0xFF718DA4);

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cyan, primaryStrong],
  );

  static const LinearGradient pageGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF031827), background],
  );
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
      dividerColor: MedixColors.borderSoft,
      splashColor: MedixColors.primary.withValues(alpha: .10),
      highlightColor: MedixColors.primary.withValues(alpha: .06),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: MedixColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: MedixColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
      ),
      cardTheme: CardThemeData(
        color: MedixColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: MedixColors.borderSoft),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: Color(0xFF03111D),
        indicatorColor: Color(0x33139BFF),
        height: 68,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(
            color: MedixColors.textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: MedixColors.surface,
        hintStyle: const TextStyle(color: MedixColors.textMuted),
        labelStyle: const TextStyle(color: MedixColors.textSecondary),
        prefixIconColor: MedixColors.textSecondary,
        suffixIconColor: MedixColors.textSecondary,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: MedixColors.borderSoft),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(
            color: MedixColors.primary,
            width: 1.4,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: MedixColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(48, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: MedixColors.surfaceElevated,
        selectedColor: MedixColors.primary,
        side: const BorderSide(color: MedixColors.borderSoft),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
        labelStyle: const TextStyle(
          color: MedixColors.textPrimary,
          fontSize: 12,
        ),
      ),
    );
  }
}
