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
    
    final title = blog['title']?.toString() ?? 'Blog Detail';
    
    // Content body: checks 'description' first (schema default) then 'content'
    final rawContent = (blog['description'] != null && blog['description'].toString().trim().isNotEmpty)
        ? blog['description']
        : (blog['content'] ?? '');
    final content = rawContent.toString().trim();

    final image = blog['image'] ?? '';
    final imageUrl = ApiConstants.resolveImage(image.toString());

    // Handle astrologer / author info
    final astrologer = blog['astrologer_id'];
    String authorName = '';
    String? authorPic;

    if (astrologer is Map) {
      if (astrologer['personal_details'] is Map) {
        authorName = astrologer['personal_details']?['name']?.toString() ?? '';
        final pic = astrologer['personal_details']?['profile_image'];
        if (pic != null && pic.toString().isNotEmpty) {
          authorPic = ApiConstants.resolveImage(pic.toString());
        }
      }
      if (authorName.trim().isEmpty) {
        authorName = astrologer['name']?.toString() ?? '';
      }
      if (authorPic == null || authorPic.isEmpty) {
        final pic = astrologer['profilePic'] ?? astrologer['profile_image'];
        if (pic != null && pic.toString().isNotEmpty) {
          authorPic = ApiConstants.resolveImage(pic.toString());
        }
      }
    }

    // Fallback to blog['post_by'] or blog['author']
    if (authorName.trim().isEmpty) {
      if (blog['post_by'] != null && blog['post_by'].toString().trim().isNotEmpty) {
        authorName = blog['post_by'].toString().trim();
      } else if (blog['author'] != null && blog['author'].toString().trim().isNotEmpty) {
        authorName = blog['author'].toString().trim();
      } else {
        authorName = 'પંડિત નરસિંહભાઈ પટેલ';
      }
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
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 260.h,
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
                    size: 90.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            leading: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Colors.black45,
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
                          'જ્યોતિષ બ્લોગ',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        dateStr,
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    title,
                    style: AppTextStyles.h2.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  SizedBox(height: 18.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
                    ),
                    child: Row(
                      children: [
                        ClipOval(
                          child: (authorPic != null && authorPic.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: authorPic,
                                  width: 44.w,
                                  height: 44.w,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 44.w,
                                    height: 44.w,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    width: 44.w,
                                    height: 44.w,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.person, color: AppColors.primary, size: 24.sp),
                                  ),
                                )
                              : Container(
                                  width: 44.w,
                                  height: 44.w,
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: Icon(Icons.person, color: AppColors.primary, size: 24.sp),
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                authorName,
                                style: AppTextStyles.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'વૈદિક જ્યોતિષાચાર્ય',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 22.h),
                  Text(
                    content,
                    style: AppTextStyles.bodyLarge.copyWith(
                      height: 1.7,
                      fontSize: 15.sp,
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
