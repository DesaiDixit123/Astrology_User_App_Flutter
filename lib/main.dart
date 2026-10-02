import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:dio/dio.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_theme_controller.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/app_pages.dart';
import 'core/localization/app_language_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/services/notification_service.dart';
import 'core/constants/api_constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase safely
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase init error: $e');
  }

  // Initialize Notifications safely
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification init error: $e');
  }

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Put controllers safely
  try {
    final languageController = Get.put(AppLanguageController(), permanent: true);
    await languageController.loadSavedLanguage();
  } catch (e) {
    debugPrint('LanguageController init error: $e');
  }

  try {
    Get.put(AppThemeController(), permanent: true);
  } catch (e) {
    debugPrint('ThemeController init error: $e');
  }

  // Non-blocking background IP resolution
  _resolveBaseUrlAsync();

  // Launch UI immediately
  runApp(const MyApp());
}

void _resolveBaseUrlAsync() {
  if (ApiConstants.baseUrl.startsWith('https://')) {
    return; // Using live production URL
  }
  Future.microtask(() async {
    try {
      if (await _checkIpPort(ApiConstants.baseUrl)) {
        return;
      }

      final subnets = <String>{};
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            final parts = addr.address.split('.');
            if (parts.length == 4) {
              subnets.add('${parts[0]}.${parts[1]}.${parts[2]}');
            }
          }
        }
      }

      if (subnets.isNotEmpty) {
        final futures = <Future<String?>>[];
        for (var subnet in subnets) {
          for (var i = 1; i <= 254; i++) {
            final ip = '$subnet.$i';
            futures.add(_checkIpForBackend(ip, 3050));
          }
        }
        final results = await Future.wait(futures);
        final foundIp = results.firstWhere((ip) => ip != null, orElse: () => null);
        if (foundIp != null) {
          ApiConstants.updateBaseUrl(foundIp);
        }
      }
    } catch (e) {
      debugPrint('Auto-IP resolution background error: $e');
    }
  });
}

Future<String?> _checkIpForBackend(String ip, int port) async {
  try {
    final socket = await Socket.connect(ip, port, timeout: const Duration(milliseconds: 300));
    socket.destroy();
    return ip;
  } catch (_) {
    return null;
  }
}

Future<bool> _checkIpPort(String urlStr) async {
  try {
    final dio = Dio(BaseOptions(connectTimeout: const Duration(milliseconds: 400)));
    final response = await dio.get('$urlStr/health');
    return response.statusCode == 200;
  } catch (_) {
    return false;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<AppLanguageController>();
    final themeController = Get.find<AppThemeController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return Obx(
          () => GetMaterialApp(
            title: 'Vedikvani Wellness',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeController.themeMode.value,
            initialRoute: AppRoutes.splash,
            getPages: AppPages.routes,
            translations: AppTranslations(),
            locale: languageController.currentLocale.value,
            fallbackLocale: AppLanguageController.supportedLanguages.first.locale,
            supportedLocales: AppLanguageController.supportedLanguages
                .map((language) => language.locale)
                .toList(),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
          ),
        );
      },
    );
  }
}
