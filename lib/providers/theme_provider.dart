import 'package:flutter/material.dart';
import '../services/theme_service.dart';

/// Provider for managing theme state
class ThemeProvider extends ChangeNotifier {
  final ThemeService _themeService = ThemeService();
  bool _isDarkMode = false;

  /// Get current dark mode state
  bool get isDarkMode => _isDarkMode;

  /// Get current theme mode
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;

  /// Initialize provider and load saved theme
  Future<void> initialize() async {
    _isDarkMode = await _themeService.getIsDarkMode();
    notifyListeners();
  }

  /// Toggle between light and dark mode
  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    await _themeService.setIsDarkMode(_isDarkMode);
    notifyListeners();
  }

  /// Set specific theme mode
  Future<void> setDarkMode(bool isDark) async {
    if (_isDarkMode != isDark) {
      _isDarkMode = isDark;
      await _themeService.setIsDarkMode(_isDarkMode);
      notifyListeners();
    }
  }
}
