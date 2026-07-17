import 'dart:ui';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

class AppLanguageOption {
  const AppLanguageOption({
    required this.code,
    required this.label,
    required this.locale,
  });

  final String code;
  final String label;
  final Locale locale;
}

class AppLanguageController extends GetxController {
  static const supportedLanguages = [
    AppLanguageOption(
      code: 'en',
      label: 'English',
      locale: Locale('en', 'US'),
    ),
    AppLanguageOption(
      code: 'hi',
      label: 'हिंदी',
      locale: Locale('hi', 'IN'),
    ),
    AppLanguageOption(
      code: 'gu',
      label: 'ગુજરાતી',
      locale: Locale('gu', 'IN'),
    ),
  ];

  final Rx<Locale> currentLocale = supportedLanguages.first.locale.obs;

  String get currentLanguageCode => currentLocale.value.languageCode;

  String get currentLanguageLabel =>
      supportedLanguages
          .firstWhere(
            (language) => language.code == currentLanguageCode,
            orElse: () => supportedLanguages.first,
          )
          .label;

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(AppConstants.keyLanguage);
    final language = _findLanguage(savedCode);
    currentLocale.value = language.locale;
  }

  Future<void> changeLanguage(String code) async {
    final language = _findLanguage(code);
    if (language.code == currentLanguageCode) {
      return;
    }

    currentLocale.value = language.locale;
    await Get.updateLocale(language.locale);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, language.code);
  }

  AppLanguageOption _findLanguage(String? code) {
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
