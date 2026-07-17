import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends GetView<AuthController> {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(gradient: AppColors.parchmentGradient),
        child: SafeArea(
          bottom: false,
          child: Stack(
            children: [
              Positioned(
                left: -40.w,
                top: 80.h,
                child: Icon(
                  Icons.hourglass_bottom_rounded,
                  size: 180.sp,
                  color: AppColors.primaryDark.withValues(alpha: 0.08),
                ),
              ),
              Positioned(
                // right: 50.w,
                // top: 68.h,
                child: Text(
                  'ॐ',
                  style: AppTextStyles.displayLarge.copyWith(
                    color: AppColors.accent.withValues(alpha: 0.9),
                    fontSize: 42.sp,
                  ),
                ),
              ),
              Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: ZoomIn(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 28.w),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 28.w,
                                vertical: 20.h,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppColors.sacredGradient,
                                borderRadius: BorderRadius.circular(28.r),
                                boxShadow: AppColors.luxuryShadow,
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 42.sp,
                                    color: AppColors.secondaryLight,
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Vedikvani Wellness',
                                    style: AppTextStyles.displayMedium.copyWith(
                                      color: Colors.white,
                                      fontSize: 34.sp,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'welcome_back'.tr,
                              style: AppTextStyles.h2.copyWith(
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'login_desc'.tr,
                              textAlign: TextAlign.center,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: FadeInUp(
                      duration: const Duration(milliseconds: 800),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 0),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(40.r),
                          ),
                          boxShadow: AppColors.luxuryShadow,
                        ),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'enter_phone'.tr,
                                style: AppTextStyles.h2.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'verify_desc'.tr,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: 40.h),

                              PremiumCard(
                                padding: EdgeInsets.zero,
                                borderRadius: 18,
                                child: CustomTextField(
                                  controller: controller.phoneController,
                                  hintText: 'phone_number'.tr,
                                  prefixIcon: Icons.phone_android_rounded,
                                  keyboardType: TextInputType.phone,
                                ),
                              ),

                              SizedBox(height: 32.h),

                              Obx(
                                () => CustomButton(
                                  text: 'send_otp'.tr,
                                  onPressed: controller.sendOTP,
                                  isLoading: controller.isLoading.value,
                                  gradient: AppColors.sacredGradient,
                                  borderRadius: 18,
                                ),
                              ),

                              SizedBox(height: 32.h),

                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  children: [
                                    Text(
                                      'by_continuing'.tr,
                                      style: AppTextStyles.caption.copyWith(
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Text(
                                        'terms_conditions'.tr,
                                        style: AppTextStyles.caption.copyWith(
                                          color: AppColors.accent,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 100.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
