import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum ThemeMode {
  light,
  dark,
  system,
}

class ThemeService {
  static const String _themeKey = 'theme_mode';
  late SharedPreferences _prefs;
  late ThemeMode _currentTheme;

  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    final savedTheme = _prefs.getString(_themeKey);
    _currentTheme = _parseThemeMode(savedTheme);
  }

  ThemeMode get currentTheme => _currentTheme;

  Future<void> setTheme(ThemeMode theme) async {
    _currentTheme = theme;
    await _prefs.setString(_themeKey, theme.toString());
  }

  bool get isDarkMode {
    if (_currentTheme == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformDispatcher.views.first.display.platformDispatcher.accessibilityFeatures.invertColors;
    }
    return _currentTheme == ThemeMode.dark;
  }

  ThemeMode _parseThemeMode(String? value) {
    if (value == null) return ThemeMode.system;
    try {
      return ThemeMode.values.firstWhere((e) => e.toString() == value);
    } catch (_) {
      return ThemeMode.system;
    }
  }
}
