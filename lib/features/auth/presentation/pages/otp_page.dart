import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../controllers/auth_controller.dart';

class OtpPage extends GetView<AuthController> {
  const OtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              FadeInDown(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'verification'.tr,
                      style: AppTextStyles.displayMedium.copyWith(
                        fontSize: 32.sp,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => RichText(
                        text: TextSpan(
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textHint,
                          ),
                          children: [
                            TextSpan(
                              text: 'enter_six_digit'.tr,
                            ),
                            TextSpan(
                              text: controller.phoneNumber.value,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
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

              SizedBox(height: 32.h),

              // Internal OTP Display (for testing/demo)
              Obx(
                () => controller.serverOtp.value.isNotEmpty
                    ? FadeIn(
                        child: Container(
                          margin: EdgeInsets.only(bottom: 32.h),
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: AppColors.primary.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primary,
                                size: 20.sp,
                              ),
                              SizedBox(width: 12.w),
                              // Text(
                              //   'Demo OTP: ${controller.serverOtp.value}',
                              //   style: AppTextStyles.bodyMedium.copyWith(
                              //     color: AppColors.primary,
                              //     fontWeight: FontWeight.bold,
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) => _buildOTPBox(index)),
                ),
              ),

              SizedBox(height: 48.h),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        'didnt_receive_code'.tr,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textHint,
                        ),
                      ),
                      TextButton(
                        onPressed: () =>
                            controller.sendOTP(navigateToOtp: false),
                        child: Text(
                          'resend_code'.tr,
                          style: AppTextStyles.buttonSmall.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Obx(
                  () => CustomButton(
                    text: 'verify_continue'.tr,
                    onPressed: controller.verifyOTP,
                    isLoading: controller.isLoading.value,
                    gradient: AppColors.cosmicGradient,
                    // borderRadius: 16,
                  ),
                ),
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPBox(int index) {
    return Container(
      width: 48.w,
      height: 60.h,
      child: PremiumCard(
        padding: EdgeInsets.zero,
        borderRadius: 16,
        child: RawKeyboardListener(
          focusNode: FocusNode(),
          onKey: (event) {
            if (event is RawKeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.backspace &&
                controller.otpControllers[index].text.isEmpty &&
                index > 0) {
              controller.otpFocusNodes[index - 1].requestFocus();
            }
          },
          child: TextField(
            controller: controller.otpControllers[index],
            focusNode: controller.otpFocusNodes[index],
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            showCursor: false,
            style: AppTextStyles.h2.copyWith(
              height: 1.2,
              color: AppColors.primary,
            ),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                if (index < 5) {
                  controller.otpFocusNodes[index + 1].requestFocus();
                } else {
                  controller.otpFocusNodes[index].unfocus();
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
