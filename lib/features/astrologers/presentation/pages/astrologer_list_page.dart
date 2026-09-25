import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/gujarati_script_utils.dart';
import '../../../../core/utils/astrologer_utils.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/astrologer_controller.dart';

class AstrologerListPage extends StatefulWidget {
  const AstrologerListPage({super.key});

  @override
  State<AstrologerListPage> createState() => _AstrologerListPageState();
}

class _AstrologerListPageState extends State<AstrologerListPage> {
  final controller = Get.find<AstrologerController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        controller.loadAstrologers();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('astrologers_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              _showFilterBottomSheet();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.astrologers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.astrologers.isEmpty && !controller.isLoading.value) {
                return Center(child: Text('no_astrologers_found'.tr));
              }

              return RefreshIndicator(
                onRefresh: () => controller.loadAstrologers(refresh: true),
                child: ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.all(16.w),
                  itemCount: controller.astrologers.length + (controller.hasMore.value ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == controller.astrologers.length) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }
                    final astrologer = controller.astrologers[index];
                    return _buildAstrologerCard(astrologer);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextField(
        onChanged: controller.search,
        decoration: InputDecoration(
          hintText: 'search_astrologers_hint'.tr,
          border: InputBorder.none,
          icon: Icon(Icons.search, color: AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final filters = [
        {'label': 'all'.tr, 'value': ''},
        {'label': 'online'.tr, 'value': 'online'},
        {'label': 'chat'.tr, 'value': 'chat'},
        {'label': 'call'.tr, 'value': 'call'},
        {'label': 'video_call'.tr, 'value': 'video_call'},
      ];
      final selectedValue = controller.filterType.value;
      return SizedBox(
        height: 50.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          itemCount: filters.length,
          itemBuilder: (context, index) {
            final filter = filters[index];
            final isSelected = selectedValue == filter['value'];
            return Container(
              margin: EdgeInsets.only(right: 8.w),
              child: FilterChip(
                label: Text(filter['label']!),
                selected: isSelected,
                onSelected: (selected) {
                  controller.setFilter(filter['value']!);
                },
                selectedColor: AppColors.primary.withValues(alpha: 0.2),
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected ? AppColors.primary : AppColors.textPrimary,
                ),
                checkmarkColor: AppColors.primary,
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildAstrologerCard(Map astrologer) {
    // Null-safe helpers for real API fields
    final name = AstrologerUtils.getLocalizedAstrologerName(astrologer);
    // Specialization fallback
    final skills = astrologer['skills'];
    final specialization = (skills is List && skills.isNotEmpty)
        ? skills.first.toString()
        : astrologer['specialization'] as String? ?? 'Astrologer';

    final rating = astrologer['rating'] ?? 0;

    // Experience fallback
    final expRaw = astrologer['experience'] ?? astrologer['experience_years'];
    final experience = expRaw != null ? '${expRaw}yr' : 'N/A';

    final price = astrologer['pricePerMinute'] ?? astrologer['price'] ?? 0;
    final isOnline = (astrologer['is_online'] ?? astrologer['isOnline']) as bool? ?? false;
    final profilePic = (astrologer['profile_pic'] ?? astrologer['profilePic']) as String?;

    return GestureDetector(
      onTap: () {
        Get.toNamed(
          AppRoutes.astrologerDetail,
          arguments: Map.from(astrologer),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 35.r,
                  backgroundColor: AppColors.primary,
                  backgroundImage: profilePic != null && profilePic.isNotEmpty
                      ? NetworkImage(ApiConstants.resolveImage(profilePic))
                      : null,
                  child: (profilePic == null || profilePic.isEmpty)
                      ? const Icon(Icons.person, color: Colors.white)
                      : null,
                ),
                if (isOnline)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 12.w,
                      height: 12.h,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
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
                    AstrologerUtils.getLocalizedAstrologerName(astrologer),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    specialization,
                    style: AppTextStyles.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 16.sp),
                      SizedBox(width: 4.w),
                      Text('$rating', style: AppTextStyles.caption),
                      SizedBox(width: 12.w),
                      Icon(
                        Icons.work_outline,
                        color: AppColors.textSecondary,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(experience, style: AppTextStyles.caption),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Obx(() {
                  if (controller.isFreeChatEligible.value) {
                    return Container(
                      margin: EdgeInsets.only(bottom: 4.h),
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(4.r),
                        border: Border.all(color: const Color(0xFFFFB74D), width: 0.5.w),
                      ),
                      child: Text(
                        '${controller.freeChatDurationMinutes.value} Min Free Chat',
                        style: TextStyle(
                          color: const Color(0xFFE65100),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                Text(
                  '₹$price/min',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.grey.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    isOnline ? 'online'.tr : 'offline'.tr,
                    style: AppTextStyles.caption.copyWith(
                      color: isOnline ? Colors.green : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('filter_astrologers'.tr, style: AppTextStyles.h4),
            SizedBox(height: 20.h),
            Text('specialization'.tr, style: AppTextStyles.bodyMedium),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: Size(double.infinity, 45.h),
              ),
              child: Text('apply_filters'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
