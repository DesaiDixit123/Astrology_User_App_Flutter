import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_dropdown_field.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../controllers/profile_controller.dart';

class EditProfilePage extends GetView<ProfileController> {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('edit_profile_title'.tr)),
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          Obx(
                            () => CircleAvatar(
                              radius: 60.r,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                              backgroundImage: controller.imageFile.value != null
                                  ? FileImage(controller.imageFile.value!)
                                  : (controller.profileImageUrl.isNotEmpty
                                      ? NetworkImage(controller.profileImageUrl)
                                      : null) as ImageProvider?,
                              child: controller.imageFile.value == null &&
                                      controller.profileImageUrl.isEmpty
                                  ? Icon(Icons.person, size: 60.sp, color: AppColors.primary)
                                  : null,
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: controller.pickImage,
                              child: Container(
                                padding: EdgeInsets.all(8.w),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt,
                                  size: 20.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    CustomTextField(
                      controller: controller.nameController,
                      hintText: 'enter_your_name'.tr,
                      labelText: 'full_name'.tr,
                      prefixIcon: Icons.person_outline,
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: controller.emailController,
                      hintText: 'enter_your_email'.tr,
                      labelText: 'email'.tr,
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16.h),
                    GestureDetector(
                      onTap: () => controller.selectDate(context),
                      child: CustomTextField(
                        controller: controller.dobController,
                        hintText: 'select_dob'.tr,
                        labelText: 'date_of_birth'.tr,
                        prefixIcon: Icons.calendar_today,
                        enabled: false,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => controller.selectTime(context),
                            child: CustomTextField(
                              controller: controller.birthTimeController,
                              hintText: 'birth_time'.tr,
                              labelText: 'birth_time'.tr,
                              prefixIcon: Icons.access_time,
                              enabled: false,
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Obx(
                            () => CustomDropdownField<String>(
                              labelText: 'gender'.tr,
                              hintText: 'select'.tr,
                              value: controller.selectedGender.value,
                              items: [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text('male'.tr, style: AppTextStyles.bodyMedium),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text('female'.tr, style: AppTextStyles.bodyMedium),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text('other_gender'.tr, style: AppTextStyles.bodyMedium),
                                ),
                              ],
                              onChanged: (v) => controller.setGender(v ?? ''),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    CustomTextField(
                      controller: controller.birthPlaceController,
                      hintText: 'city_state_country'.tr,
                      labelText: 'place_of_birth'.tr,
                      prefixIcon: Icons.location_on_outlined,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Obx(
                            () => CustomDropdownField<String>(
                              labelText: 'marital_status'.tr,
                              hintText: 'select'.tr,
                              value: controller.selectedMaritalStatus.value,
                              items: [
                                DropdownMenuItem(
                                  value: 'Single',
                                  child: Text('single'.tr, style: AppTextStyles.bodyMedium),
                                ),
                                DropdownMenuItem(
                                  value: 'Married',
                                  child: Text('married'.tr, style: AppTextStyles.bodyMedium),
                                ),
                                DropdownMenuItem(
                                  value: 'Divorced',
                                  child: Text('divorced'.tr, style: AppTextStyles.bodyMedium),
                                ),
                                DropdownMenuItem(
                                  value: 'Widowed',
                                  child: Text('widowed'.tr, style: AppTextStyles.bodyMedium),
                                ),
                              ],
                              onChanged: (v) => controller.selectedMaritalStatus.value = v ?? '',
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: CustomTextField(
                            controller: controller.occupationController,
                            hintText: 'occupation_hint'.tr,
                            labelText: 'occupation'.tr,
                            prefixIcon: Icons.work_outline,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 32.h),
                    Obx(
                      () => CustomButton(
                        text: 'save_changes'.tr,
                        isLoading: controller.isSaving.value,
                        onPressed: controller.updateProfile,
                        gradient: AppColors.primaryGradient,
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom + 40.h),
                  ],
                ),
              ),
      ),
    );
  }
}
