import 'package:flutter_bloc/flutter_bloc.dart';
import '../enums/theme_type.dart';
import '../utils/app_theme.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(ThemeState.initial());

  void toggleTheme() {
    if (state.themeType == AppThemeType.dark) {
      emit(
        state.copyWith(
          themeType: AppThemeType.light,
          themeData: AppTheme.light,
        ),
      );
    } else {
      emit(
        state.copyWith(
          themeType: AppThemeType.dark,
          themeData: AppTheme.dark,
        ),
      );
    }
  }

  void setDark() {
    emit(
      state.copyWith(
        themeType: AppThemeType.dark,
        themeData: AppTheme.dark,
      ),
    );
  }

  void setLight() {
    emit(
      state.copyWith(
        themeType: AppThemeType.light,
        themeData: AppTheme.light,
      ),
    );
  }
}