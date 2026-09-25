import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../controllers/service_controller.dart';

class HoroscopePage extends GetView<ServiceController> {
  const HoroscopePage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.ensureHoroscopeSignsLoaded();
    return Scaffold(
      appBar: AppBar(
        title: Text('horoscope_title'.tr),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('daily_horoscope'.tr, style: AppTextStyles.h3),
                  SizedBox(height: 8.h),
                  Text(
                    'select_sign_desc'.tr,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
          Obx(() {
            if (controller.isHoroscopeSignsLoading.value &&
                controller.horoscopeSigns.isEmpty) {
              return const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (controller.horoscopeSigns.isEmpty) {
              return SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'No horoscope signs found.',
                          style: AppTextStyles.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: controller.loadHoroscopeSigns,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.w,
                  mainAxisSpacing: 16.h,
                  childAspectRatio: 0.83,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final sign = (controller.horoscopeSigns[index] as Map)
                      .cast<String, dynamic>();
                  return InkWell(
                    onTap: () =>
                        Get.toNamed(AppRoutes.horoscopeDetail, arguments: sign),
                    borderRadius: BorderRadius.circular(20.r),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20.r),
                              ),
                              child: SizedBox(
                                width: double.infinity,
                                child: Image.network(
                                  ApiConstants.resolveImage(
                                    sign['sign_image']?.toString() ?? '',
                                  ),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: const BoxDecoration(
                                        gradient: AppColors.parchmentGradient,
                                      ),
                                      alignment: Alignment.center,
                                      child: Icon(
                                        Icons.auto_awesome,
                                        size: 42.sp,
                                        color: AppColors.primary,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(14.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  sign['sign_name']?.toString() ?? '',
                                  style: AppTextStyles.h4,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  sign['description']?.toString() ?? '',
                                  style: AppTextStyles.bodySmall,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }, childCount: controller.horoscopeSigns.length),
              ),
            );
          }),
          SliverToBoxAdapter(
            child: Obx(
              () => controller.isHoroscopeSignsLoading.value
                  ? Padding(
                      padding: EdgeInsets.only(top: 16.h),
                      child: const Center(child: CircularProgressIndicator()),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
          SliverToBoxAdapter(
            child: Builder(
              builder: (context) {
                final bottomPadding = MediaQuery.of(context).padding.bottom;
                return SizedBox(height: 36.h + bottomPadding);
              },
            ),
          ),
        ],
      ),
    );
  }
}
