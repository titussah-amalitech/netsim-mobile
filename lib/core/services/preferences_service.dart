// lib/core/services/preferences_service.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _themeModeKey = 'theme_mode';
  static const _onboardingCompleteKey = 'onboarding_complete';

  SharedPreferences? _prefs;

  Future<SharedPreferences> get prefs async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  Future<ThemeMode?> getThemeMode() async {
    final instance = await prefs;
    final mode = instance.getString(_themeModeKey);
    if (mode == 'dark') return ThemeMode.dark;
    if (mode == 'light') return ThemeMode.light;
    return null;
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final instance = await prefs;
    await instance.setString(_themeModeKey, mode.name);
  }

  Future<bool> isOnboardingComplete() async {
    final instance = await prefs;
    return instance.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> setOnboardingComplete(bool value) async {
    final instance = await prefs;
    await instance.setBool(_onboardingCompleteKey, value);
  }
}
