import 'package:shared_preferences/shared_preferences.dart';

/// Service for persisting theme preferences
class ThemeService {
  static const String _themeKey = 'is_dark_mode';

  /// Get saved theme mode (default: false = light mode)
  Future<bool> getIsDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  /// Save theme mode preference
  Future<void> setIsDarkMode(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }
}
