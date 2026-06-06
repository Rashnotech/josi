import 'package:flutter/material.dart';

import 'josi_colors.dart';

class JosiTheme {
  const JosiTheme._();

  static ThemeData get light {
    final TextTheme textTheme = const TextTheme(
      displayLarge:
          TextStyle(fontSize: 40, fontWeight: FontWeight.w800, height: 1.05),
      headlineLarge:
          TextStyle(fontSize: 30, fontWeight: FontWeight.w800, height: 1.12),
      headlineMedium:
          TextStyle(fontSize: 24, fontWeight: FontWeight.w800, height: 1.18),
      titleLarge:
          TextStyle(fontSize: 20, fontWeight: FontWeight.w700, height: 1.22),
      titleMedium:
          TextStyle(fontSize: 17, fontWeight: FontWeight.w700, height: 1.25),
      titleSmall:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w700, height: 1.25),
      bodyLarge:
          TextStyle(fontSize: 16, fontWeight: FontWeight.w500, height: 1.45),
      bodyMedium:
          TextStyle(fontSize: 14, fontWeight: FontWeight.w500, height: 1.45),
      bodySmall:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 1.35),
      labelLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w800, height: 1.2),
      labelMedium:
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700, height: 1.2),
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
        labelStyle: textTheme.labelMedium?.copyWith(color: JosiColors.muted),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.line),
          borderRadius: BorderRadius.circular(16),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.red, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: JosiColors.redDark, width: 1.5),
          borderRadius: BorderRadius.circular(16),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size.fromHeight(54),
          foregroundColor: JosiColors.ink,
          side: const BorderSide(color: JosiColors.line),
          textStyle: textTheme.labelLarge,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
