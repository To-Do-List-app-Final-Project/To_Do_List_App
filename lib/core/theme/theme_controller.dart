// lib/core/theme/theme_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  // Observable themeMode to track current theme
  var themeMode = ThemeMode.system.obs;

  // Keys for shared preferences
  static const String themeModeKey = 'themeMode';

  @override
  void onInit() {
    super.onInit();
    loadThemeMode();
  }

  // Load saved theme mode from shared preferences
  Future<void> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? themeModeString = prefs.getString(themeModeKey);

    if (themeModeString != null) {
      if (themeModeString == 'dark') {
        themeMode.value = ThemeMode.dark;
      } else if (themeModeString == 'light') {
        themeMode.value = ThemeMode.light;
      } else {
        themeMode.value = ThemeMode.system;
      }
    }
  }

  // Change theme and save to shared preferences
  Future<void> changeThemeMode(ThemeMode mode) async {
    themeMode.value = mode;

    SharedPreferences prefs = await SharedPreferences.getInstance();

    switch (mode) {
      case ThemeMode.dark:
        await prefs.setString(themeModeKey, 'dark');
        break;
      case ThemeMode.light:
        await prefs.setString(themeModeKey, 'light');
        break;
      default:
        await prefs.setString(themeModeKey, 'system');
    }
  }

  // Toggle between light and dark mode
  Future<void> toggleTheme() async {
    if (themeMode.value == ThemeMode.light) {
      await changeThemeMode(ThemeMode.dark);
    } else {
      await changeThemeMode(ThemeMode.light);
    }
  }

  // Check if current theme is dark
  bool get isDarkMode {
    if (themeMode.value == ThemeMode.system) {
      return Get.isPlatformDarkMode;
    }
    return themeMode.value == ThemeMode.dark;
  }
}
