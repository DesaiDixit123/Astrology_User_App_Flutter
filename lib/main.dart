import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'config/routes/app_routes.dart';
import 'config/routes/app_pages.dart';
import 'core/localization/app_language_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/services/notification_service.dart';
import 'core/constants/api_constants.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Notifications
  await NotificationService().initialize();

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

  final languageController = Get.put(AppLanguageController(), permanent: true);
  await languageController.loadSavedLanguage();

  await _resolveBaseUrl();

  runApp(const MyApp());
}

Future<void> _resolveBaseUrl() async {
  // First check if the currently hardcoded one works
  if (await _checkIpPort(ApiConstants.baseUrl)) {
    return; // Already good
  }

  // Attempt to find all local IPs and scan their subnets
  try {
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
      final tasks = <Future<String?>>[];
      for (final subnet in subnets) {
        for (int i = 1; i <= 254; i++) {
          final ip = '$subnet.$i';
          tasks.add(_checkIpForBackend(ip, 3050));
        }
      }
      
      final results = await Future.wait(tasks);
      final foundIp = results.firstWhere((ip) => ip != null, orElse: () => null);
      
      if (foundIp != null) {
        ApiConstants.updateBaseUrl('http://$foundIp:3050');
        print('✅ Dynamic Backend Resolved: ${ApiConstants.baseUrl}');
      } else {
        print('❌ Could not find backend on local network.');
      }
    }
  } catch (e) {
    print('Error resolving base URL: $e');
  }
}

Future<bool> _checkIpPort(String url) async {
  try {
    final uri = Uri.parse(url);
    final host = uri.host;
    if (host.isEmpty) return false;
    final port = uri.hasPort ? uri.port : (uri.scheme == 'https' ? 443 : 80);
    final socket = await Socket.connect(host, port, timeout: const Duration(seconds: 1));
    socket.destroy();
    return true;
  } catch (_) {
    return false;
  }
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

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Widget? _appInstance;

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<AppLanguageController>();

    return ScreenUtilInit(
      designSize: const Size(375, 812), // iPhone X design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        // Cache the app instance to prevent LateInitializationErrors during transitions
        _appInstance ??= GetMaterialApp(
          title: 'Vedikvani Wellness',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
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
        );
        return _appInstance!;
      },
    );
  }
}
