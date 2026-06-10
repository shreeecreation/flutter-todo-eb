import 'package:flutter/material.dart';

import '../enums/theme_type.dart';
import '../utils/app_theme.dart';

class ThemeState {
  final ThemeData themeData;
  final AppThemeType themeType;

  const ThemeState({
    required this.themeData,
    required this.themeType,
  });

  factory ThemeState.initial() {
    return ThemeState(
      themeData: AppTheme.dark,
      themeType: AppThemeType.dark,
    );
  }

  ThemeState copyWith({
    ThemeData? themeData,
    AppThemeType? themeType,
  }) {
    return ThemeState(
      themeData: themeData ?? this.themeData,
      themeType: themeType ?? this.themeType,
    );
  }
}