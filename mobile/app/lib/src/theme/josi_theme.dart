import 'package:flutter/material.dart';

import 'josi_colors.dart';

class JosiTheme {
  const JosiTheme._();

  static ThemeData get light {
    final TextTheme textTheme = const TextTheme(
      displayLarge: TextStyle(fontSize: 42, fontWeight: FontWeight.w800, height: 1.02),
      headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, height: 1.08),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.12),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.18),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.22),
      bodyLarge: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, height: 1.38),
      bodyMedium: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, height: 1.42),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, height: 1.2),
      labelMedium: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, height: 1.2),
    ).apply(
      bodyColor: JosiColors.ink,
      displayColor: JosiColors.ink,
      fontFamily: 'Inter',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: Colors.white,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: JosiColors.red,
        onPrimary: Colors.white,
        secondary: JosiColors.black,
        onSecondary: Colors.white,
        surface: Colors.white,
        onSurface: JosiColors.ink,
      ),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: JosiColors.black,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JosiColors.surface,
        border: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(18),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide.none,
          borderRadius: BorderRadius.circular(18),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.red, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.redDark, width: 1.5),
          borderRadius: BorderRadius.circular(18),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          elevation: 0,
          backgroundColor: JosiColors.red,
          foregroundColor: Colors.white,
          disabledBackgroundColor: JosiColors.surfaceStrong,
          disabledForegroundColor: JosiColors.muted,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return JosiColors.red;
          }
          return Colors.white;
        }),
        side: const BorderSide(color: JosiColors.line, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }
}
