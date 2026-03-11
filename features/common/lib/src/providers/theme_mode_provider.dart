import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:common/src/services.dart';

part 'theme_mode_provider.g.dart';

@riverpod
class ThemeModeController extends _$ThemeModeController {
  @override
  ThemeMode build() {
    // Load persisted value asynchronously, default to system
    _loadThemeMode();
    return ThemeMode.system;
  }

  Future<void> _loadThemeMode() async {
    final modeString = await PreferencesService.getThemeMode();
    state = _themeModeFromString(modeString);
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    await PreferencesService.setThemeMode(_themeModeToString(mode));
    state = mode;
  }

  static ThemeMode _themeModeFromString(String value) {
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  static String _themeModeToString(ThemeMode mode) {
    return switch (mode) {
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
      ThemeMode.system => 'system',
    };
  }
}
