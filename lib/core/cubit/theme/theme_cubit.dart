import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState(themeMode: ThemeMode.light)) {
    _loadTheme();
  }

  static const String _themeKey = 'theme';

  // Load the saved theme from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(_themeKey);

    if (savedTheme != null) {
      emit(ThemeState(
        themeMode: savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light,
      ));
    }
  }

  // Toggle the theme and save the preference
  Future<void> toggleTheme() async {
    final newThemeMode =
        state.themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;

    // Save the new theme preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _themeKey, newThemeMode == ThemeMode.dark ? 'dark' : 'light');

    // Emit the new state
    emit(ThemeState(themeMode: newThemeMode));
  }
}
