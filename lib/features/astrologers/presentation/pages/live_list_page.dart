import 'package:astrology_user/config/routes/app_routes.dart';
import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/features/live/presentation/controllers/live_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class LiveListPage extends GetView<LiveController> {
  const LiveListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Astrologers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.liveStreams.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.videocam_off, size: 64.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('No live sessions currently', style: AppTextStyles.bodyLarge),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.all(16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 0.8,
          ),
          itemCount: controller.liveStreams.length,
          itemBuilder: (context, index) {
            final session = (controller.liveStreams[index] as Map).cast<String, dynamic>();
            final partner = (session['astrologer_id'] is Map) 
              ? (session['astrologer_id'] as Map).cast<String, dynamic>()
              : {};
            
            final name = partner['name']?.toString().trim().isNotEmpty == true
                ? partner['name'].toString()
                : (partner['personal_details'] is Map
                    ? partner['personal_details']['name']?.toString() ?? 'Astrologer'
                    : 'Astrologer');

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
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
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
                              : Text('Join Now', style: AppTextStyles.caption.copyWith(color: AppColors.primary)),
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
