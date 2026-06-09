import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF6750A4);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seedColor,
        brightness: Brightness.light,
        inputDecorationTheme: _inputTheme,
        // cardTheme: CardThemeData()..copyWith(_cardTheme),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        colorSchemeSeed: _seedColor,
        brightness: Brightness.dark,
        inputDecorationTheme: _inputTheme,
        // cardTheme: _cardTheme,
      );

  static const _inputTheme = InputDecorationTheme(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    isDense: true,
  );

  static const _cardTheme = CardTheme(
    elevation: 0,
    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
}