import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../network/api_service.dart';
import '../constants/api_constants.dart';
import '../localization/app_language_controller.dart';
import '../../../config/routes/app_routes.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // 1. Request Permissions
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (kDebugMode) {
      print('User granted permission: ${settings.authorizationStatus}');
    }

    // 2. Setup Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.isNotEmpty) {
          try {
            final Map<String, dynamic> data = jsonDecode(details.payload!);
            handleNotificationNavigation(data);
          } catch (e) {
            if (kDebugMode) print('Error parsing user notification payload: $e');
          }
        }
      },
    );

    // 3. Handle Foreground Messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('User got foreground message: ${message.data}');
      }

      if (message.notification != null) {
        _showLocalNotification(message);
      }
    });

    // 4. Handle Background Message Taps
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      if (kDebugMode) {
        print('User onMessageOpenedApp: ${message.data}');
      }
      handleNotificationNavigation(message.data);
    });

    // 5. Handle Terminated App Launch from Notification
    final RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print('User launched from terminated notification: ${initialMessage.data}');
      }
      Future.delayed(const Duration(milliseconds: 600), () {
        handleNotificationNavigation(initialMessage.data);
      });
    }

    // 6. Get and Sync Token
    await syncToken();

    // 7. Listen for token refreshes
    _fcm.onTokenRefresh.listen((newToken) {
      _updateTokenInBackend(newToken);
    });
  }

  static void handleNotificationNavigation(Map<String, dynamic> data) {
    if (data.isEmpty) return;
    if (kDebugMode) print('User Navigating from notification data: $data');

    final type = data['type']?.toString().toLowerCase() ?? '';
    final sessionId = data['session_id']?.toString() ?? data['sessionId']?.toString() ?? '';
    final astrologerId = data['astrologer_id']?.toString() ?? data['astrologerId']?.toString() ?? '';
    final astrologerName = data['astrologer_name']?.toString() ?? 'Astrologer';
    final astrologerPic = data['astrologer_pic']?.toString() ?? data['profile_pic']?.toString() ?? '';

    final partner = {
      '_id': astrologerId,
      'name': astrologerName,
      'profile_pic': astrologerPic,
    };

    if (type == 'chat' || type == 'new_chat_session') {
      if (sessionId.isEmpty && astrologerId.isEmpty) return;
      Get.toNamed(
        AppRoutes.chat,
        arguments: {
          'sessionId': sessionId,
          'partner': partner,
          'readonly': false,
        },
      );
    } else if (type == 'call' || type == 'voice_call') {
      Get.toNamed(
        AppRoutes.voiceCall,
        arguments: {
          'sessionId': sessionId,
          'channel': data['channel'] ?? '',
          'token': data['agora_token'] ?? '',
          'appId': data['agora_app_id'] ?? '',
          'partner': partner,
        },
      );
    } else if (type == 'video_call') {
      Get.toNamed(
        AppRoutes.videoCall,
        arguments: {
          'sessionId': sessionId,
          'channel': data['channel'] ?? '',
          'token': data['agora_token'] ?? '',
          'appId': data['agora_app_id'] ?? '',
          'partner': partner,
        },
      );
    } else if (type == 'live' || type == 'live_stream') {
      final liveId = data['live_id']?.toString() ?? '';
      if (liveId.isNotEmpty) {
        Get.toNamed(
          AppRoutes.liveViewer,
          arguments: {
            'live_id': liveId,
            'channel_name': data['channel_name'] ?? liveId,
            'token': data['token'] ?? '',
            'astrologer_name': astrologerName,
            'astrologer_image': astrologerPic,
          },
        );
      }
    } else if (type == 'order' || type == 'shop_order') {
      Get.toNamed(AppRoutes.shopOrders);
    } else if (type == 'puja' || type == 'puja_order') {
      Get.toNamed(AppRoutes.pujaHistory);
    } else if (type == 'calendar' || type == 'choghadiya') {
      Get.toNamed(AppRoutes.calendar);
    } else if (type == 'panchang') {
      Get.toNamed(AppRoutes.panchang);
    }
  }

  Future<void> syncToken() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.iOS || defaultTargetPlatform == TargetPlatform.macOS) {
        String? apnsToken = await _fcm.getAPNSToken();
        if (apnsToken == null) {
          await Future.delayed(const Duration(seconds: 3));
          apnsToken = await _fcm.getAPNSToken();
        }
      }

      String? token = await _fcm.getToken();
      if (token != null) {
        if (kDebugMode) {
          print("User FCM Token: $token");
        }
        await _updateTokenInBackend(token);
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error getting FCM token: $e");
      }
    }
  }

  Future<void> _updateTokenInBackend(String token) async {
    try {
      final lang = Get.isRegistered<AppLanguageController>()
          ? Get.find<AppLanguageController>().currentLanguageCode
          : 'en';
      await ApiService.instance.put(
        ApiConstants.profile,
        data: {
          'fcm_token': token,
          'language': lang,
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print("Error syncing FCM token: $e");
      }
    }
  }

  void _showLocalNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidPlatformChannelSpecifics =
        const AndroidNotificationDetails(
      'astrology_user_channel', // id
      'Astrology Notifications', // title
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: const DarwinNotificationDetails(),
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: jsonEncode(message.data),
    );
  }
}
