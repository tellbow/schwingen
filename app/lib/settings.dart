import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  Settings._(this._prefs);

  static const _theme = 'theme';
  static const _language = 'language';

  final SharedPreferencesWithCache _prefs;

  static Future<Settings> load() async => Settings._(
    await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(allowList: {_theme, _language}),
    ),
  );

  ThemeMode get themeMode => ThemeMode.values.asNameMap()[_prefs.getString(_theme)] ?? ThemeMode.system;

  Locale? get locale => switch (_prefs.getString(_language)) {
    final code? => Locale(code),
    null => null,
  };

  Future<void> setThemeMode(ThemeMode mode) => _set(_theme, mode == ThemeMode.system ? null : mode.name);

  Future<void> setLocale(Locale? locale) => _set(_language, locale?.languageCode);

  Future<void> _set(String key, String? value) async {
    await (value == null ? _prefs.remove(key) : _prefs.setString(key, value));
    notifyListeners();
  }
}
