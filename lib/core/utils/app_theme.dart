import 'package:flutter/material.dart';

abstract final class AppTheme {
  static const _seedColor = Color(0xFF90e0ef);
  
static ThemeData get light => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      
      inputDecorationTheme: _inputTheme,
    );

static ThemeData get dark => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Color(0xFF080708),
      colorSchemeSeed: _seedColor,
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