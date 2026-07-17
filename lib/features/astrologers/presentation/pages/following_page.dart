import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../config/routes/app_routes.dart';
import '../controllers/astrologer_controller.dart';
import 'astrologer_detail_page.dart';

class FollowingPage extends StatefulWidget {
  const FollowingPage({super.key});

  @override
  State<FollowingPage> createState() => _FollowingPageState();
}

class _FollowingPageState extends State<FollowingPage> {
  final AstrologerController controller = Get.find<AstrologerController>();

  @override
  void initState() {
    super.initState();
    controller.loadFollowing();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Following',
          style: AppTextStyles.h3.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: Obx(() {
        final list = controller.following;
        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.favorite_border, size: 64.sp, color: Colors.grey[400]),
                SizedBox(height: 16.h),
                Text(
                  'No Following Yet',
                  style: AppTextStyles.h3.copyWith(color: Colors.grey[700]),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Follow your favorite astrologers to stay updated!',
                  style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey[500]),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: EdgeInsets.all(16.w),
          itemCount: list.length,
          separatorBuilder: (context, index) => SizedBox(height: 12.h),
          itemBuilder: (context, index) {
            final astro = list[index] as Map<String, dynamic>;
            final name = astro['name']?.toString() ?? 'Astrologer';
            final skillsList = astro['skills'];
            final specialization = (skillsList is List && skillsList.isNotEmpty)
                ? skillsList.first.toString()
                : (astro['specialization']?.toString() ?? 'Vedic Astrologer');
            final profilePic = astro['profilePic'] ?? astro['profile_pic'];
            final id = (astro['_id'] ?? astro['id'])?.toString() ?? '';

            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                leading: CircleAvatar(
                  radius: 28.r,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  backgroundImage: (profilePic != null && profilePic.toString().isNotEmpty)
                      ? NetworkImage(profilePic.toString())
                      : null,
                  child: (profilePic == null || profilePic.toString().isEmpty)
                      ? Icon(Icons.person, color: AppColors.primary, size: 28.sp)
                      : null,
                ),
                title: Text(name, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                subtitle: Text(specialization, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey[600])),
                trailing: OutlinedButton.icon(
                  onPressed: () {
                    if (id.isNotEmpty) {
                      controller.toggleFollow(id);
                    }
                  },
                  icon: Icon(Icons.favorite, color: AppColors.primary, size: 16.sp),
                  label: Text(
                    'Following',
                    style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.4)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                  ),
                ),
                onTap: () {
                  Get.toNamed(
                    AppRoutes.astrologerDetail,
                    arguments: Map.from(astro),
                  );
                },
              ),
            );
          },
        );
      }),
    );
  }
}
