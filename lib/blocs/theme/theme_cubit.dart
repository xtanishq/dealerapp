import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ThemeCubit extends Cubit<ThemeMode> {
  static const String _themePrefKey = 'theme_mode';

  ThemeCubit() : super(ThemeMode.system) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeString = prefs.getString(_themePrefKey);
    
    if (themeModeString != null) {
      // Convert string back to ThemeMode
      switch (themeModeString) {
        case 'light':
          emit(ThemeMode.light);
          break;
        case 'dark':
          emit(ThemeMode.dark);
          break;
        default:
          emit(ThemeMode.system);
      }
    }
  }

  Future<void> toggleTheme() async {
    final newTheme = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme(newTheme);
    emit(newTheme);
  }

  Future<void> setTheme(ThemeMode mode) async {
    await _saveTheme(mode);
    emit(mode);
  }

  Future<void> _saveTheme(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert ThemeMode to string for storage
    String themeModeString;
    switch (mode) {
      case ThemeMode.light:
        themeModeString = 'light';
        break;
      case ThemeMode.dark:
        themeModeString = 'dark';
        break;
      default:
        themeModeString = 'system';
    }
    
    await prefs.setString(_themePrefKey, themeModeString);
  }
}
