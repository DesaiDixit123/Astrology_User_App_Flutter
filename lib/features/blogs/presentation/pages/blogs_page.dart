import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/blog_controller.dart';

class BlogsPage extends GetView<BlogController> {
  const BlogsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('latest_blog'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.blogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.blogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.article_outlined, size: 64.sp, color: AppColors.textHint),
                SizedBox(height: 16.h),
                Text('no_data_found'.tr),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadBlogs(refresh: true),
          child: ListView.separated(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.blogs.length + (controller.hasMore.value ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              if (index == controller.blogs.length) {
                controller.loadBlogs();
                return const Center(child: CircularProgressIndicator());
              }

              final blog = controller.blogs[index];
              return _buildBlogCard(blog);
            },
          ),
        );
      }),
    );
  }

  Widget _buildBlogCard(Map blog) {
    final title = blog['title'] ?? '';
    final summary = blog['description'] ?? '';
    final image = blog['image'] ?? '';
    final imageUrl = image.toString().startsWith('http')
        ? image.toString()
        : '${ApiConstants.imageBaseUrl}/$image';

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

    return GestureDetector(
      onTap: () => Get.toNamed('/blog-detail', arguments: blog),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                height: 140.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Icon(Icons.article, size: 64.sp, color: AppColors.primary),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Blog',
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(dateStr, style: AppTextStyles.caption),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(title, style: AppTextStyles.h4, maxLines: 2, overflow: TextOverflow.ellipsis),
                  SizedBox(height: 4.h),
                  Text(
                    summary,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        'Read More',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(Icons.arrow_forward_ios, size: 12.sp, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
