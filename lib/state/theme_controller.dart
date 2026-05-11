import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'theme_mode';

class ThemeController extends ChangeNotifier {
  ThemeController(this._prefs);

  final SharedPreferences _prefs;
  ThemeMode _mode = ThemeMode.light;

  ThemeMode get themeMode => _mode;

  void loadSaved() {
    final s = _prefs.getString(_key);
    _mode = switch (s) {
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => ThemeMode.light,
    };
    notifyListeners();
  }

  // Theme Toggle
  Future<void> setThemeMode(ThemeMode mode) async {
    _mode = mode;
    final value = switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
    await _prefs.setString(_key, value);
    notifyListeners();
  }

  Future<void> toggle() async {
    await setThemeMode(
      _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
  }

  bool get isLight =>
      _mode == ThemeMode.light ||
      (_mode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.light);
}
