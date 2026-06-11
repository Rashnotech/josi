import 'package:flutter/material.dart';

import 'josi_colors.dart';

class JosiTheme {
  const JosiTheme._();

  static ThemeData get light {
    final TextTheme textTheme = const TextTheme(
      displayLarge:
          TextStyle(fontSize: 32, fontWeight: FontWeight.w700, height: 1.12),
      headlineLarge:
          TextStyle(fontSize: 24, fontWeight: FontWeight.w700, height: 1.18),
      headlineMedium:
          TextStyle(fontSize: 22, fontWeight: FontWeight.w600, height: 1.18),
      titleLarge:
          TextStyle(fontSize: 18, fontWeight: FontWeight.w600, height: 1.22),
      titleMedium:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.25),
      titleSmall:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.25),
      bodyLarge:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.4),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.4),
      bodySmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.35),
      labelLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w600, height: 1.2),
      labelMedium:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
    ).apply(
      bodyColor: JosiColors.ink,
      displayColor: JosiColors.ink,
      fontFamily: 'Inter',
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',
      scaffoldBackgroundColor: JosiColors.surface,
      textTheme: textTheme,
      colorScheme: const ColorScheme.light(
        primary: JosiColors.red,
        onPrimary: JosiColors.white,
        secondary: JosiColors.charcoal,
        onSecondary: JosiColors.white,
        error: JosiColors.redDark,
        onError: JosiColors.white,
        surface: JosiColors.white,
        onSurface: JosiColors.ink,
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: JosiColors.surface,
        foregroundColor: JosiColors.ink,
        titleTextStyle: textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: JosiColors.white,
        hintStyle: textTheme.bodyMedium?.copyWith(color: JosiColors.softMuted),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: JosiColors.softMuted,
          letterSpacing: 0,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.line),
          borderRadius: BorderRadius.circular(4),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.line),
          borderRadius: BorderRadius.circular(4),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.charcoal, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.redDark, width: 1.5),
          borderRadius: BorderRadius.circular(4),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          elevation: 0,
          backgroundColor: JosiColors.red,
          foregroundColor: JosiColors.white,
          disabledBackgroundColor: JosiColors.surfaceStrong,
          disabledForegroundColor: JosiColors.muted,
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: JosiColors.ink,
          side: const BorderSide(color: JosiColors.line),
          textStyle: textTheme.labelLarge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: JosiColors.red,
          textStyle: textTheme.labelLarge,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        elevation: 0,
        backgroundColor: JosiColors.white,
        indicatorColor: JosiColors.redSoft,
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle?>(
            (Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return textTheme.labelMedium
              ?.copyWith(color: selected ? JosiColors.red : JosiColors.muted);
        }),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
            (Set<WidgetState> states) {
          final bool selected = states.contains(WidgetState.selected);
          return IconThemeData(
              color: selected ? JosiColors.red : JosiColors.muted, size: 24);
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((Set<WidgetState> states) {
          if (states.contains(WidgetState.selected)) {
            return JosiColors.red;
          }
          return JosiColors.white;
        }),
        side: const BorderSide(color: JosiColors.line, width: 1.4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
    );
  }
}
