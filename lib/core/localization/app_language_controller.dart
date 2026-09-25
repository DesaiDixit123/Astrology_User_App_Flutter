import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';
import '../../features/home/presentation/controllers/home_controller.dart';
import '../../features/astrologers/presentation/controllers/astrologer_controller.dart';
import '../../features/live/presentation/controllers/live_controller.dart';
import '../../features/blogs/presentation/controllers/blog_controller.dart';

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
      label: '🇺🇸 English',
      locale: Locale('en', 'US'),
    ),
    AppLanguageOption(
      code: 'hi',
      label: '🇮🇳 हिन्दी',
      locale: Locale('hi', 'IN'),
    ),
    AppLanguageOption(
      code: 'gu',
      label: '🇮🇳 ગુજરાતી',
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

    // Save language code first so API headers pick up the new language immediately
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyLanguage, language.code);

    currentLocale.value = language.locale;
    await Get.updateLocale(language.locale);

    // Refresh active controllers so dynamic data and headers update seamlessly
    _refreshActiveControllers();
  }

  void _refreshActiveControllers() {
    try {
      if (Get.isRegistered<HomeController>()) {
        Get.find<HomeController>().loadData();
      }
      if (Get.isRegistered<AstrologerController>()) {
        Get.find<AstrologerController>().loadAstrologers();
      }
      if (Get.isRegistered<LiveController>()) {
        Get.find<LiveController>().loadLiveStreams();
      }
      if (Get.isRegistered<BlogController>()) {
        Get.find<BlogController>().loadBlogs(refresh: true);
      }
    } catch (e) {
      debugPrint('Error refreshing controllers on language change: $e');
    }
  }

  AppLanguageOption _findLanguage(String? code) {
    return supportedLanguages.firstWhere(
      (language) => language.code == code,
      orElse: () => supportedLanguages.first,
    );
  }
}
