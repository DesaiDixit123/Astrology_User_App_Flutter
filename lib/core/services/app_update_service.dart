import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../network/api_service.dart';

class AppUpdateService {
  static bool _isDialogShowing = false;

  /// Checks whether an app update is required.
  /// If force_update is true, displays an un-dismissible popup and returns true.
  /// Otherwise returns false.
  static Future<bool> checkForUpdate() async {
    try {
      final response = await ApiService.instance.get(
        ApiConstants.appVersionCheck,
        queryParameters: {
          'app_type': 'user',
          'current_version': AppConstants.appVersion,
        },
      );

      if (response == null || response['Data'] == null) {
        return false;
      }

      final updateData = response['Data'] as Map<String, dynamic>;
      final bool forceUpdate = updateData['force_update'] == true;
      final String latestVersion = (updateData['latest_version'] ?? '').toString();
      final String marketUrl = (updateData['play_store_url'] ?? '').toString();
      final String webUrl = (updateData['web_url'] ?? '').toString();

      // Retrieve localized text
      final lang = Get.locale?.languageCode ?? 'gu';
      String title = 'એપ અપડેટ જરૂરી છે';
      String message =
          'એપનું નવું વર્ઝન ઉપલબ્ધ છે. આગળ વધવા માટે કૃપા કરીને Google Play Store પરથી એપ અપડેટ કરો.';

      if (updateData['title'] is Map) {
        title = (updateData['title'][lang] ??
                updateData['title']['gu'] ??
                updateData['title']['en'] ??
                title)
            .toString();
      }
      if (updateData['message'] is Map) {
        message = (updateData['message'][lang] ??
                updateData['message']['gu'] ??
                updateData['message']['en'] ??
                message)
            .toString();
      }

      if (forceUpdate && !_isDialogShowing) {
        _showForceUpdateDialog(
          title: title,
          message: message,
          latestVersion: latestVersion,
          marketUrl: marketUrl.isNotEmpty
              ? marketUrl
              : 'market://details?id=${AppConstants.androidPackageName}',
          webUrl: webUrl.isNotEmpty
              ? webUrl
              : 'https://play.google.com/store/apps/details?id=${AppConstants.androidPackageName}',
        );
        return true;
      }

      return false;
    } catch (e) {
      debugPrint('[AppUpdateService] Version check error: $e');
      return false;
    }
  }

  /// Opens Google Play Store directly on Android device
  static Future<void> openPlayStore({
    required String marketUrl,
    required String webUrl,
  }) async {
    try {
      final marketUri = Uri.parse(marketUrl);
      final webUri = Uri.parse(webUrl);

      if (await canLaunchUrl(marketUri)) {
        await launchUrl(marketUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint('[AppUpdateService] Launch URL error: $e');
      try {
        final fallbackUri = Uri.parse(
          'https://play.google.com/store/apps/details?id=${AppConstants.androidPackageName}',
        );
        await launchUrl(fallbackUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  /// Displays an un-dismissible Force Update Dialog
  static void _showForceUpdateDialog({
    required String title,
    required String message,
    required String latestVersion,
    required String marketUrl,
    required String webUrl,
  }) {
    _isDialogShowing = true;

    Get.dialog(
      PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {},
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          elevation: 10,
          backgroundColor: Colors.white,
          insetPadding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon / Visual Badge
                Container(
                  width: 80.w,
                  height: 80.w,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9933), Color(0xFFFF6600)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF9933).withOpacity(0.35),
                        blurRadius: 16.r,
                        offset: Offset(0, 6.h),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.system_update_rounded,
                      size: 42.sp,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1F222E),
                  ),
                ),
                SizedBox(height: 10.h),

                // Version comparison pill
                if (latestVersion.isNotEmpty)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Text(
                      'v${AppConstants.appVersion}  ➔  v$latestVersion',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ),
                SizedBox(height: 12.h),

                // Description Message
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14.sp,
                    height: 1.45,
                    color: const Color(0xFF616161),
                  ),
                ),
                SizedBox(height: 26.h),

                // Update Now Button (Cannot be bypassed)
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF9933),
                      foregroundColor: Colors.white,
                      elevation: 3,
                      shadowColor: const Color(0xFFFF9933).withOpacity(0.4),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    onPressed: () => openPlayStore(
                      marketUrl: marketUrl,
                      webUrl: webUrl,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.shop_two_rounded, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          _getUpdateButtonText(),
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  static String _getUpdateButtonText() {
    final lang = Get.locale?.languageCode ?? 'gu';
    if (lang == 'hi') return 'अभी अपडेट करें';
    if (lang == 'en') return 'Update Now';
    return 'હમણાં અપડેટ કરો';
  }
}
