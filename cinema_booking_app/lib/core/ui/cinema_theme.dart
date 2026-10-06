import 'package:flutter/material.dart';

abstract final class CinemaColors {
  static const background = Color(0xFF0E0B0B);
  static const card = Color(0xFF1B1616);
  static const surface = Color(0xFF262020);
  static const red = Color(0xFFE3242B);
  static const text = Color(0xFFF4F1EE);
  static const muted = Color(0xFFA89E99);
  static const success = Color(0xFF3FBF6F);
  static const warning = Color(0xFFF2B233);
}

abstract final class CinemaTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: CinemaColors.background,
    colorScheme: const ColorScheme.dark(
      primary: CinemaColors.red,
      surface: CinemaColors.card,
      onSurface: CinemaColors.text,
      secondary: CinemaColors.success,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      backgroundColor: CinemaColors.background,
      foregroundColor: CinemaColors.text,
    ),
    cardTheme: CardThemeData(
      color: CinemaColors.card,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: CinemaColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: CinemaColors.red,
        foregroundColor: Colors.white,
        minimumSize: const Size(0, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}
