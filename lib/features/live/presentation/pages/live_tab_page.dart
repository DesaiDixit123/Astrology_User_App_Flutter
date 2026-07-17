import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/live_controller.dart';
import 'live_viewer_page.dart';

class LiveTabPage extends GetView<LiveController> {
  const LiveTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Live'),
        actions: [
          IconButton(
            onPressed: () => controller.refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.liveStreams.isEmpty) {
          return Center(
            child: Text(
              'No one is live right now',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refresh(),
          child: ListView.separated(
            padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w, bottom: 100.h),
            itemCount: controller.liveStreams.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final stream = (controller.liveStreams[index] as Map).cast<String, dynamic>();
              final astrologer = (stream['astrologer_id'] as Map?)?.cast<String, dynamic>() ?? {};
              final name = astrologer['name']?.toString().trim().isNotEmpty == true
                  ? astrologer['name'].toString()
                  : (astrologer['personal_details'] is Map
                      ? astrologer['personal_details']['name']?.toString() ?? 'Astrologer'
                      : 'Astrologer');

              final profilePic = astrologer['profile_pic']?.toString().trim().isNotEmpty == true
                  ? astrologer['profile_pic'].toString()
                  : (astrologer['personal_details'] is Map
                      ? astrologer['personal_details']['profile_image']?.toString() ?? ''
                      : '');

              final viewers = (stream['viewers_count'] ?? 0).toString();

              return Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 26.r,
                          backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                          backgroundImage: profilePic.isNotEmpty
                              ? CachedNetworkImageProvider(ApiConstants.resolveImage(profilePic))
                              : null,
                          child: profilePic.isEmpty
                              ? Icon(Icons.person, color: AppColors.primary, size: 26.sp)
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Text(
                              'LIVE',
                              style: AppTextStyles.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w700),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            (stream['title']?.toString().trim().isNotEmpty == true)
                                ? stream['title'].toString()
                                : 'Live Session',
                            style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            children: [
                              Icon(Icons.visibility, size: 14.sp, color: AppColors.textSecondary),
                              SizedBox(width: 4.w),
                              Text(
                                viewers,
                                style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 10.w),
                    ElevatedButton(
                      onPressed: () async {
                        final join = await controller.joinStream(stream['_id'].toString());
                        if (join == null) return;
                        Get.to(
                          () => const LiveViewerPage(),
                          arguments: {
                            'stream': stream,
                            'join': join,
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                      child: Text(
                        'Join',
                        style: AppTextStyles.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

