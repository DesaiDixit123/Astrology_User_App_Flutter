import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/astrologer_utils.dart';
import '../../../../core/utils/name_transliteration_utils.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
          _buildCategorySwitch(),
          _buildFilterChips(),
          Expanded(
            child: Obx(() {
              final isAi = controller.selectedCategory.value == 'ai';

              if (isAi) {
                final aiList = controller.filteredAiAstrologers;
                if (aiList.isEmpty) {
                  return Center(child: Text('no_astrologers_found'.tr));
                }
                return RefreshIndicator(
                  onRefresh: () => controller.loadAiAstrologers(),
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 120.h),
                    itemCount: aiList.length,
                    itemBuilder: (context, index) {
                      return _buildAstrologerCard(aiList[index]);
                    },
                  ),
                );
              }

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
                  padding: EdgeInsets.fromLTRB(16.w, 16.w, 16.w, 120.h),
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

  Widget _buildCategorySwitch() {
    return Obx(() {
      final isAi = controller.selectedCategory.value == 'ai';
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F1F5),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedCategory.value = 'all',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: !isAi ? AppColors.primary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      '🌟 ${'vedic_astrologers'.tr}',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: !isAi ? Colors.white : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.selectedCategory.value = 'ai',
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: isAi ? AppColors.secondary : Colors.transparent,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '🤖 ${'ai_astrologers'.tr}',
                          style: AppTextStyles.bodySmall.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAi ? Colors.white : AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: isAi ? Colors.white.withValues(alpha: 0.25) : AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            '${NameTransliterationUtils.toLocalizedNumber(6)} AI',
                            style: TextStyle(
                              color: isAi ? Colors.white : AppColors.primary,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChips() {
    return Obx(() {
      final isAi = controller.selectedCategory.value == 'ai';
      if (isAi) {
        final count6 = NameTransliterationUtils.toLocalizedNumber(6);
        final count3 = NameTransliterationUtils.toLocalizedNumber(3);
        final aiFilters = [
          {'label': 'all_ai_filter'.trArgs([count6]), 'value': 'all'},
          {'label': 'boy_ai_filter'.trArgs([count3]), 'value': 'boy'},
          {'label': 'girl_ai_filter'.trArgs([count3]), 'value': 'girl'},
        ];
        final selectedVal = controller.selectedAiGender.value;
        return SizedBox(
          height: 44.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: aiFilters.length,
            itemBuilder: (context, index) {
              final filter = aiFilters[index];
              final isSelected = selectedVal == filter['value'];
              return Container(
                margin: EdgeInsets.only(right: 8.w),
                child: FilterChip(
                  label: Text(filter['label']!),
                  selected: isSelected,
                  onSelected: (selected) {
                    controller.selectedAiGender.value = filter['value']!;
                  },
                  selectedColor: AppColors.secondary.withValues(alpha: 0.2),
                  labelStyle: AppTextStyles.bodySmall.copyWith(
                    color: isSelected ? AppColors.secondary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  checkmarkColor: AppColors.secondary,
                ),
              );
            },
          ),
        );
      }

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
    final bool isAi = astrologer['is_ai'] == true ||
        (astrologer['_id']?.toString().startsWith('6aa00000000000000000000') ?? false);
    final gender = astrologer['gender']?.toString() ?? '';

    // Null-safe helpers for real API fields
    final name = AstrologerUtils.getLocalizedAstrologerName(astrologer);
    // Specialization localized
    final specialization = AstrologerUtils.getLocalizedAstrologerSpecialization(astrologer);

    final ratingVal = astrologer['rating'] ?? 5.0;
    final rating = NameTransliterationUtils.toLocalizedNumber(ratingVal);

    // Experience fallback
    final expRaw = astrologer['experience'] ?? astrologer['experience_years'];
    final expNum = expRaw != null ? NameTransliterationUtils.toLocalizedNumber(expRaw) : NameTransliterationUtils.toLocalizedNumber(10);
    final experience = '${expNum}yr';

    final price = isAi ? 0 : (astrologer['pricePerMinute'] ?? astrologer['price'] ?? 0);
    final isOnline = isAi ? true : ((astrologer['is_online'] ?? astrologer['isOnline']) as bool? ?? false);
    final profilePic = AstrologerUtils.getAstrologerImage(astrologer);

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
                ClipOval(
                  child: SizedBox(
                    width: 70.r,
                    height: 70.r,
                    child: isAi
                        ? _buildAiAvatar(astrologer, 70.r)
                        : (profilePic.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ApiConstants.resolveImage(profilePic),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.primary,
                                  child: const Icon(Icons.person, color: Colors.white),
                                ),
                              )
                            : Container(
                                color: AppColors.primary,
                                child: const Icon(Icons.person, color: Colors.white),
                              )),
                  ),
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isAi)
                        Container(
                          margin: EdgeInsets.only(left: 4.w),
                          padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                          decoration: BoxDecoration(
                            color: (gender == 'boy' ? Colors.blue : Colors.purple).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            gender == 'boy' ? 'boy_tag'.tr : 'girl_tag'.tr,
                            style: TextStyle(
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                              color: gender == 'boy' ? Colors.blue[700] : Colors.purple[700],
                            ),
                          ),
                        ),
                    ],
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
                      Text(rating, style: AppTextStyles.caption),
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
                if (!isAi)
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
                if (isAi)
                  Obx(() {
                    final isFree = controller.isAiFreeAvailable.value;
                    final aiPrice = controller.aiChatPrice.value;
                    return Text(
                      isFree ? 'FREE' : '₹$aiPrice',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isFree ? const Color(0xFF2E7D32) : AppColors.textPrimary,
                      ),
                    );
                  })
                else
                  Text(
                    '₹$price/min',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
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
                    isAi ? 'AI 24/7' : (isOnline ? 'online'.tr : 'offline'.tr),
                    style: AppTextStyles.caption.copyWith(
                      color: isOnline ? Colors.green : Colors.grey,
                      fontWeight: FontWeight.bold,
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

  Widget _buildAiAvatar(Map astro, double size) {
    final name = (astro['name'] ?? '').toString();

    List<Color> gradientColors;
    IconData iconData;
    IconData faceIcon;

    if (name.contains('Aarav')) {
      gradientColors = const [Color(0xFFFF9933), Color(0xFFFF5722)];
      iconData = Icons.auto_awesome;
      faceIcon = Icons.face;
    } else if (name.contains('Rohan')) {
      gradientColors = const [Color(0xFF1E3C72), Color(0xFF2A5298)];
      iconData = Icons.insights_rounded;
      faceIcon = Icons.face;
    } else if (name.contains('Gautam')) {
      gradientColors = const [Color(0xFF00796B), Color(0xFF004D40)];
      iconData = Icons.diamond_outlined;
      faceIcon = Icons.face;
    } else if (name.contains('Ragini')) {
      gradientColors = const [Color(0xFFE91E63), Color(0xFFFF6090)];
      iconData = Icons.spa_rounded;
      faceIcon = Icons.face_3;
    } else if (name.contains('Shloka')) {
      gradientColors = const [Color(0xFF7B1FA2), Color(0xFF4A148C)];
      iconData = Icons.style_rounded;
      faceIcon = Icons.face_3;
    } else {
      gradientColors = const [Color(0xFFD81B60), Color(0xFF880E4F)];
      iconData = Icons.visibility_rounded;
      faceIcon = Icons.face_3;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: gradientColors[0].withValues(alpha: 0.35),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            faceIcon,
            color: Colors.white,
            size: size * 0.58,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                iconData,
                color: const Color(0xFFFFD54F),
                size: size * 0.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
