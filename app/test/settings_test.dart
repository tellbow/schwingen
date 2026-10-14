import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/in_memory_shared_preferences_async.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:tellbow/settings.dart';

void main() {
  setUp(() => SharedPreferencesAsyncPlatform.instance = InMemorySharedPreferencesAsync.empty());

  test('follows the phone by default', () async {
    final settings = await Settings.load();
    expect(settings.themeMode, ThemeMode.system);
    expect(settings.locale, isNull);
  });

  test('keeps theme and language for the next start', () async {
    final settings = await Settings.load();
    await settings.setThemeMode(ThemeMode.dark);
    await settings.setLocale(const Locale('fr'));

    final reloaded = await Settings.load();
    expect(reloaded.themeMode, ThemeMode.dark);
    expect(reloaded.locale, const Locale('fr'));
  });

  test('goes back to the phone setting', () async {
    final settings = await Settings.load();
    await settings.setThemeMode(ThemeMode.light);
    await settings.setLocale(const Locale('de'));
    await settings.setThemeMode(ThemeMode.system);
    await settings.setLocale(null);

    final reloaded = await Settings.load();
    expect(reloaded.themeMode, ThemeMode.system);
    expect(reloaded.locale, isNull);
  });

  test('tells listeners about every change', () async {
    final settings = await Settings.load();
    var changes = 0;
    settings.addListener(() => changes++);
    await settings.setThemeMode(ThemeMode.dark);
    await settings.setLocale(const Locale('fr'));
    expect(changes, 2);
  });
}
