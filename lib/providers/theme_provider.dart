import 'package:flutter/material.dart';
import '../services/theme_service.dart';

class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService;
  late ThemeMode _currentTheme;

  ThemeProvider(this._themeService) {
    _currentTheme = _themeService.currentTheme;
  }

  ThemeMode get currentTheme => _currentTheme;

  bool get isDarkMode => _currentTheme == ThemeMode.dark;

  Future<void> setTheme(ThemeMode theme) async {
    _currentTheme = theme;
    await _themeService.setTheme(theme);
    notifyListeners();
  }

  void toggleTheme() async {
    final newTheme = _currentTheme == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await setTheme(newTheme);
  }
}
