import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/app_colors.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarUtil {
  static void show({
    required String message,
    required SnackbarType type,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    Get.rawSnackbar(
      title: title ?? config.title,
      message: message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: config.backgroundColor,
      icon: Icon(config.icon, color: Colors.white, size: 28),
      borderRadius: 12,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      duration: duration,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
      boxShadows: [
        BoxShadow(
          color: config.backgroundColor.withOpacity(0.3),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      snackStyle: SnackStyle.FLOATING,
    );
  }

  static void success(String message, {String? title}) {
    show(message: message, type: SnackbarType.success, title: title);
  }

  static void error(String message, {String? title}) {
    show(message: message, type: SnackbarType.error, title: title);
  }

  static void warning(String message, {String? title}) {
    show(message: message, type: SnackbarType.warning, title: title);
  }

  static void info(String message, {String? title}) {
    show(message: message, type: SnackbarType.info, title: title);
  }

  static _SnackbarConfig _getConfig(SnackbarType type) {
    switch (type) {
      case SnackbarType.success:
        return _SnackbarConfig(
          title: 'Success',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success,
        );
      case SnackbarType.error:
        return _SnackbarConfig(
          title: 'Error',
          icon: Icons.error,
          backgroundColor: AppColors.error,
        );
      case SnackbarType.warning:
        return _SnackbarConfig(
          title: 'Warning',
          icon: Icons.warning,
          backgroundColor: AppColors.warning,
        );
      case SnackbarType.info:
        return _SnackbarConfig(
          title: 'Info',
          icon: Icons.info,
          backgroundColor: AppColors.info,
        );
    }
  }
}

class _SnackbarConfig {
  final String title;
  final IconData icon;
  final Color backgroundColor;

  _SnackbarConfig({
    required this.title,
    required this.icon,
    required this.backgroundColor,
  });
}
