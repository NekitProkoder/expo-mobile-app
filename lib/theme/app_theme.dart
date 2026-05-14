import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFFFACA2C);
  static const Color primaryLight = Color(0xFFFFE58A);

  static const Color background = Color(0xFFF5F5F5);
  static const Color backgroundLight = Color(0xFFF7F7F7);

  static const Color text = Colors.black;
  static const Color mutedText = Colors.black54;

  static const double radiusSmall = 14;
  static const double radius = 18;
  static const double radiusLarge = 24;
  static const double radiusXL = 26;

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: background,
    primaryColor: primary,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      primary: primary,
      secondary: primaryLight,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: primary,
      foregroundColor: Colors.black,
      elevation: 0,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: Colors.black,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.black,
        elevation: 0,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radius),
        borderSide: const BorderSide(
          color: primary,
          width: 2,
        ),
      ),
    ),
  );
}