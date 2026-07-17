import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class BlogDetailPage extends StatelessWidget {
  const BlogDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Expecting arguments to be passed when navigating
    final Map blog = Get.arguments ?? {};
    
    final title = blog['title'] ?? 'Blog Detail';
    final content = blog['content'] ?? '';
    final image = blog['image'] ?? '';
    final imageUrl = image.toString().startsWith('http')
        ? image.toString()
        : '${ApiConstants.imageBaseUrl}/$image';

    // Handle astrologer info
    final astrologer = blog['astrologer_id'];
    String authorName = 'Astrologer';
    String? authorPic;
    if (astrologer is Map) {
      authorName = astrologer['name'] ?? 'Expert';
      authorPic = astrologer['profilePic'];
    }

    // Format date
    String dateStr = 'Recently';
    if (blog['createdAt'] != null) {
      try {
        final date = DateTime.parse(blog['createdAt']);
        dateStr = DateFormat('MMM dd, yyyy').format(date);
      } catch (e) {
        dateStr = 'Recently';
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.h,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(
                    Icons.article,
                    size: 100.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
              onPressed: () => Get.back(),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          'Astrology Blog',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTextStyles.caption,
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(title, style: AppTextStyles.h2),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: AppColors.border,
                        backgroundImage: (authorPic != null && authorPic.isNotEmpty)
                            ? NetworkImage(authorPic)
                            : null,
                        child: (authorPic == null || authorPic.isEmpty)
                            ? const Icon(Icons.person, color: Colors.grey)
                            : null,
                      ),
                      SizedBox(width: 8.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            authorName,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Expert Astrologer',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    content,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.6,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 48.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

