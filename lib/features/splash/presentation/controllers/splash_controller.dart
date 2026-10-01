import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/app_update_service.dart';

class SplashController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    _navigateToNext();
  }

  void _navigateToNext() async {
    try {
      await Future.delayed(const Duration(seconds: 2));

      // ── Check Mandatory App Update ──────────────────────────
      final needsUpdate = await AppUpdateService.checkForUpdate();
      if (needsUpdate) {
        // App is locked until updated on Play Store. Do not proceed!
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final token =
          prefs.getString(AppConstants.keyToken) ?? prefs.getString('token');
      final isLoggedIn =
          prefs.getBool(AppConstants.keyIsLoggedIn) ?? (token?.isNotEmpty ?? false);
      final profileComplete = prefs.getBool(AppConstants.keyProfileComplete) ??
          prefs.getBool('user_profile_complete') ??
          false;

      if (!isLoggedIn || token == null || token.isEmpty) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      if (profileComplete) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.register);
      }
    } catch (_) {
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
