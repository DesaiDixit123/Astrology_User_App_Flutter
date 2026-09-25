import 'package:astrology_user/config/routes/app_routes.dart';
import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/features/live/presentation/controllers/live_controller.dart';
import 'package:astrology_user/core/utils/gujarati_script_utils.dart';
import 'package:astrology_user/core/utils/astrologer_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LiveListPage extends GetView<LiveController> {
  const LiveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    controller.loadLiveStreams();

    return Scaffold(
      appBar: AppBar(
        title: Text('live_now'.tr),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.liveStreams.isEmpty) {
          return Center(
            child: Text('no_astrologers_found'.tr, style: AppTextStyles.bodyMedium),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
          ),
          itemCount: controller.liveStreams.length,
          itemBuilder: (context, index) {
            final session = (controller.liveStreams[index] as Map).cast<String, dynamic>();
            final partner = (session['astrologer_id'] is Map) 
              ? (session['astrologer_id'] as Map).cast<String, dynamic>()
              : (session['partner'] is Map ? (session['partner'] as Map).cast<String, dynamic>() : session);
            
            final name = AstrologerUtils.getLocalizedAstrologerName(session);

            final profilePic = partner['profile_image']?.toString().trim().isNotEmpty == true
                ? partner['profile_image'].toString()
                : (partner['personal_details'] is Map
                    ? partner['personal_details']['profile_image']?.toString() ?? ''
                    : '');
            
            final topic = session['title']?.toString() ?? 'Live Session';
            final viewers = session['viewers_count'] ?? 0;

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                          child: profilePic.isNotEmpty
                            ? Image.network(
                                ApiConstants.resolveImage(profilePic),
                                fit: BoxFit.cover,
                                errorBuilder: (c,e,s) => Container(color: AppColors.primary.withValues(alpha: 0.1)),
                              )
                            : Container(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                child: Icon(Icons.person, size: 64.sp, color: AppColors.primary),
                              ),
                        ),
                        Positioned(
                          top: 8.h,
                          left: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.circle, color: Colors.white, size: 8.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  'LIVE',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 8.h,
                          right: 8.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.visibility, color: Colors.white, size: 12.sp),
                                SizedBox(width: 4.w),
                                Text(
                                  '$viewers',
                                  style: AppTextStyles.caption.copyWith(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          topic,
                          style: AppTextStyles.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        SizedBox(
                          width: double.infinity,
                          child: Obx(() => OutlinedButton(
                            onPressed: controller.isJoining.value 
                              ? null 
                              : () async {
                                final joinData = await controller.joinStream(session['_id'].toString());
                                if (joinData != null) {
                                  Get.toNamed(AppRoutes.liveViewer, arguments: {
                                    'stream': session,
                                    'join': joinData,
                                  });
                                }
                              },
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 8.h),
                              side: BorderSide(color: AppColors.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            child: controller.isJoining.value 
                              ? SizedBox(height: 14.h, width: 14.h, child: const CircularProgressIndicator(strokeWidth: 2))
                              : Text('consult'.tr, style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      }),
    );
  }
}
