import 'package:flutter/material.dart';

import 'secure_storage_service.dart';

class ThemeService {
  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier(ThemeMode.light);

  static Future<void> init() async {
    final storedMode = await SecureStorageService.loadThemeMode();
    themeModeNotifier.value = _modeFromString(storedMode);
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    themeModeNotifier.value = mode;
    await SecureStorageService.saveThemeMode(_modeToString(mode));
  }

  static ThemeMode _modeFromString(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.light;
    }
  }

  static String _modeToString(ThemeMode mode) {
    return mode == ThemeMode.dark ? 'dark' : 'light';
  }
}
