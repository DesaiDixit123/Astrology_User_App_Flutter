import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class AppThemeController extends GetxController {
  final Rx<ThemeMode> themeMode = ThemeMode.light.obs;

  bool get isDarkMode => themeMode.value == ThemeMode.dark;

  String get currentThemeLabel => isDarkMode ? 'Dark' : 'Light';

  @override
  void onInit() {
    super.onInit();
    loadSavedTheme();
  }

  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString(AppConstants.keyLanguage + '_theme') ?? 'light';
    if (savedTheme == 'dark') {
      themeMode.value = ThemeMode.dark;
    } else {
      themeMode.value = ThemeMode.light;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode.value = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.keyLanguage + '_theme',
      mode == ThemeMode.dark ? 'dark' : 'light',
    );
  }
}
