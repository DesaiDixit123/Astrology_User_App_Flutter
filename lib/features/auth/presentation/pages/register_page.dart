import 'dart:io';
import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:astrology_user/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/auth_controller.dart';

class RegisterPage extends GetView<AuthController> {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('complete_profile'.tr, style: AppTextStyles.h3),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeInDown(child: _buildProfileImagePicker()),
              SizedBox(height: 32.h),

              FadeInUp(
                delay: const Duration(milliseconds: 200),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'personal_details'.tr,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: CustomTextField(
                        controller: controller.nameController,
                        hintText: 'full_name'.tr,
                        prefixIcon: Icons.person_outline_rounded,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      child: CustomTextField(
                        controller: controller.emailController,
                        hintText: 'email_optional'.tr,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    PremiumCard(
                      padding: EdgeInsets.zero,
                      onTap: () => controller.selectDate(context),
                      child: AbsorbPointer(
                        child: CustomTextField(
                          controller: controller.dobController,
                          hintText: 'date_of_birth'.tr,
                          prefixIcon: Icons.calendar_today_rounded,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 32.h),

              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'gender'.tr,
                      style: AppTextStyles.label.copyWith(fontSize: 14.sp),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => Row(
                        children: [
                          Expanded(
                            child: _buildGenderOption(
                              'Male',
                              'male'.tr,
                              Icons.male_rounded,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildGenderOption(
                              'Female',
                              'female'.tr,
                              Icons.female_rounded,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: _buildGenderOption(
                              'Other',
                              'other_gender'.tr,
                              Icons.transgender_rounded,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 48.h),

              FadeInUp(
                delay: const Duration(milliseconds: 600),
                child: Obx(
                  () => CustomButton(
                    text: 'complete_registration'.tr,
                    onPressed: controller.register,
                    isLoading: controller.isLoading.value,
                    gradient: AppColors.cosmicGradient,
                    //    borderRadius: 16,
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

  Widget _buildProfileImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: () {
          Get.bottomSheet(
            GlassContainer(
              borderRadius: 30,
              padding: EdgeInsets.symmetric(vertical: 20.h),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('select_profile_photo'.tr, style: AppTextStyles.h4),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildPickerOption(
                        Icons.photo_library_rounded,
                        'gallery'.tr,
                        ImageSource.gallery,
                      ),
                      _buildPickerOption(
                        Icons.camera_alt_rounded,
                        'camera'.tr,
                        ImageSource.camera,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        },
        child: Stack(
          children: [
            Obx(
              () => Container(
                width: 110.w,
                height: 110.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary.withValues(alpha: 0.05),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    width: 3,
                  ),
                  image: controller.selectedImage.value != null
                      ? DecorationImage(
                          image: FileImage(controller.selectedImage.value!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: controller.selectedImage.value == null
                    ? Icon(
                        Icons.person_rounded,
                        size: 50.sp,
                        color: AppColors.primary.withValues(alpha: 0.5),
                      )
                    : null,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickerOption(IconData icon, String label, ImageSource source) {
    return GestureDetector(
      onTap: () {
        controller.pickImage(source);
        Get.back();
      },
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final bool isSelected = controller.selectedGender.value == value;
    return GestureDetector(
      onTap: () => controller.setGender(value),
      child: PremiumCard(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        borderRadius: 16,
        gradientColors: isSelected
            ? [AppColors.primary, AppColors.primaryDark]
            : null,
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.textSecondary,
              size: 22.sp,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: AppTextStyles.caption.copyWith(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
