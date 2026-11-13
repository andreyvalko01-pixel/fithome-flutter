import 'package:flutter/material.dart';

const brand = Color(0xFF5B5BF6);
const brandDark = Color(0xFF1E1B4B);
const accent = Color(0xFFFF8A4C);
const surface = Color(0xFFF5F5FA);

ThemeData buildTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: brand,
    primary: brand,
    secondary: accent,
    surface: surface,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      ),
    ),
  );
}
