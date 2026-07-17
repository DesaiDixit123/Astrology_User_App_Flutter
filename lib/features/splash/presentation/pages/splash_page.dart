import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

class SplashPage extends GetView<SplashController> {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.cosmicGradient,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Subtle animated stars background
            const _StarsStaticBackground(),
            
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Pulsing Logo (Simplified to avoid animate_do crash)
                Container(
                  width: 140.w,
                  height: 140.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.3),
                        blurRadius: 40,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: Center(
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icon.png',
                        width: 120.w,
                        height: 120.w,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
                
                // Animated App Name
                Text(
                  'VEDIKVANI WELLNESS',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: Colors.white,
                    fontSize: 28.sp,
                    letterSpacing: 4,
                  ),
                ),
                SizedBox(height: 12.h),
                
                // Animated Tagline
                Text(
                  'unlock_wisdom'.tr,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white70,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
            
            // Bottom Loading Indicator
            Positioned(
              bottom: 80.h,
              child: Column(
                children: [
                  SizedBox(
                    width: 30.w,
                    height: 30.w,
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'connecting_cosmos'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarsStaticBackground extends StatelessWidget {
  const _StarsStaticBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(20, (index) {
        final double top = (index * 47) % 600 + 50.0;
        final double left = (index * 31) % 350 + 20.0;
        final double size = (index % 3 + 1).toDouble();
        
        return Positioned(
          top: top.h,
          left: left.w,
          child: Container(
            width: size.w,
            height: size.w,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: index % 2 == 0 ? 0.8 : 0.4),
              shape: BoxShape.circle,
            ),
          ),
        );
      }),
    );
  }
}
