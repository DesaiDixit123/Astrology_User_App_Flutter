import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:astrology_user/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/utils/gujarati_script_utils.dart';
import '../../../../core/utils/name_transliteration_utils.dart';
import '../../../../core/utils/astrologer_utils.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../dashboard/presentation/controllers/dashboard_controller.dart';
import '../../../live/presentation/controllers/live_controller.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.loadData,
          color: AppColors.primary,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 16.h),
                    FadeInUp(child: _buildBannerSection()),
                    _buildFreeChatBanner(),
                    _buildServicesSection(),
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: _buildAnalyzeKundaliCard(),
                    ),
                    if (controller.liveAstrologers.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildLiveAstrologersSection(),
                      ),
                    if (controller.topAstrologers.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 500),
                        child: _buildTopAstrologersSection(),
                      ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 600),
                      child: _buildBlogsSection(),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 800),
                      child: _buildWhatIsAstrologySection(),
                    ),
                    FadeInUp(
                      delay: const Duration(milliseconds: 900),
                      child: _buildAstrologyFaqsSection(),
                    ),
                    SizedBox(height: 120.h),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.h,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.deepCosmic,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 20.w, bottom: 16.h),
        title: Row(
          children: [
            ElasticIn(
              child: Icon(
                Icons.temple_hindu,
                color: AppColors.secondaryLight,
                size: 22.sp,
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'vedikvani_app_name'.tr,
              style: AppTextStyles.displayMedium.copyWith(
                color: Colors.white,
                fontSize: 24.sp,
              ),
            ),
          ],
        ),
        background: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.sacredGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
            ),
            Positioned(
              right: 125.w,
              top: 39.h,
              child: Text(
                'ॐ',
                style: AppTextStyles.h1.copyWith(
                  color: AppColors.secondaryLight.withValues(alpha: 0.35),
                  fontSize: 44.sp,
                ),
              ),
            ),
            Positioned(
              left: -18.w,
              bottom: -28.h,
              child: Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.secondaryLight.withValues(alpha: 0.08),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(right: 16.w),
          child: Row(
            children: [
              _buildAppBarAction(
                Icons.account_balance_wallet_rounded,
                () => Get.toNamed(AppRoutes.wallet),
              ),
              SizedBox(width: 12.w),
              _buildAppBarAction(Icons.notifications_active_rounded, () => Get.toNamed(AppRoutes.notifications)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBarAction(IconData icon, VoidCallback onTap) {
    return GlassContainer(
      padding: EdgeInsets.zero,
      borderRadius: 12,
      blur: 5,
      width: 40.w,
      height: 40.w,
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 20.sp),
        onPressed: onTap,
        padding: EdgeInsets.zero,
      ),
    );
  }

  Widget _buildBannerSection() {
    if (controller.banners.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 200.h,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: controller.bannerPageController,
              itemCount: controller.banners.length,
              onPageChanged: (index) {
                controller.currentBannerIndex.value = index;
              },
              itemBuilder: (context, index) {
                final banner = controller.banners[index];
                final imagePath = banner['image'];
                final isAsset = banner['isAsset'] == true || (imagePath != null && imagePath.toString().startsWith('assets/'));

                return Obx(() {
                  double scale = controller.currentBannerIndex.value == index
                      ? 1.0
                      : 0.9;
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 350),
                    tween: Tween(begin: scale, end: scale),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      return Transform.scale(scale: value, child: child);
                    },
                    child: PremiumCard(
                      margin: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      padding: EdgeInsets.zero,
                      gradientColors: isAsset
                          ? null
                          : [
                              AppColors.primaryDark,
                              AppColors.primary,
                              AppColors.accent,
                            ],
                      child: Stack(
                        children: [
                          if (isAsset && imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image.asset(
                                imagePath,
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          if (!isAsset && imagePath != null && imagePath.toString().isNotEmpty)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24.r),
                              child: Image.network(
                                ApiConstants.resolveImage(imagePath.toString()),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => Container(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                ),
                              ),
                            ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24.r),
                              gradient: LinearGradient(
                                begin: Alignment.bottomLeft,
                                end: Alignment.topRight,
                                colors: [
                                  Colors.black.withValues(alpha: 0.8),
                                  Colors.black.withValues(alpha: 0.2),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: EdgeInsets.all(20.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                GlassContainer(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 4.h,
                                  ),
                                  borderRadius: 20,
                                  child: Text(
                                    'daily_cosmic_guidance'.tr,
                                    style: AppTextStyles.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  banner['title'] ?? '',
                                  style: AppTextStyles.h3.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
              },
            ),
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                controller.banners.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  width: controller.currentBannerIndex.value == index
                      ? 24.w
                      : 8.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: controller.currentBannerIndex.value == index
                        ? AppColors.primary
                        : AppColors.textHint.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesSection() {
    final services = [
      {
        'icon': Icons.grid_on_rounded,
        'label': 'kundli_title'.tr,
        'route': AppRoutes.kundli,
        'color': [const Color(0xFFD97706), const Color(0xFFF59E0B)],
      },
      {
        'icon': Icons.favorite_rounded,
        'label': 'matchmaking_title'.tr,
        'route': AppRoutes.matchmaking,
        'color': [const Color(0xFFDC2626), const Color(0xFFEF4444)],
      },
      {
        'icon': Icons.calendar_month_rounded,
        'label': 'panchang_title'.tr,
        'route': AppRoutes.panchang,
        'color': [const Color(0xFF7C3AED), const Color(0xFF8B5CF6)],
      },
      {
        'icon': Icons.stars_rounded,
        'label': 'horoscope_title'.tr,
        'route': AppRoutes.horoscope,
        'color': [const Color(0xFF2563EB), const Color(0xFF3B82F6)],
      },
      {
        'icon': Icons.temple_hindu,
        'label': 'e_pooja_title'.tr,
        'route': AppRoutes.epooja,
        'color': [const Color(0xFF8A251B), const Color(0xFFB73716)],
      },
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'e_shop_title'.tr,
        'route': AppRoutes.shop,
        'color': [const Color(0xFF6E4A22), const Color(0xFFC89647)],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'our_services'.tr,
            style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
          ),

          GridView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.only(top: 12.h, bottom: 4.h),
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 10.h,
              childAspectRatio: 1.3,
            ),
            itemCount: services.length,
            itemBuilder: (context, index) {
              final service = services[index];
              return _buildServiceItem(service);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(Map<String, dynamic> service) {
    final List<Color> colors = service['color'] as List<Color>;
    return GestureDetector(
      onTap: () => Get.toNamed(service['route'] as String),
      child: PremiumCard(
        padding: EdgeInsets.all(12.w),
        borderRadius: 20,
        gradientColors: [
          colors[0].withValues(alpha: 0.1),
          colors[1].withValues(alpha: 0.05),
        ],
        border: Border.all(color: colors[0].withValues(alpha: 0.2)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: colors),
                boxShadow: [
                  BoxShadow(
                    color: colors[0].withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                service['icon'] as IconData,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              service['label'] as String,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLiveAstrologersSection() {
    if (controller.liveAstrologers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 8.h, bottom: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const GlowingLiveBadge(text: 'LIVE'),
                    SizedBox(width: 8.w),
                    Text(
                      'live_astrologers'.tr,
                      style: AppTextStyles.h4.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (Get.isRegistered<DashboardController>()) {
                      Get.find<DashboardController>().changeTab(2);
                    }
                  },
                  child: Text(
                    'view_all'.tr,
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: controller.liveAstrologers.length,
              itemBuilder: (context, index) {
                final astro = (controller.liveAstrologers[index] as Map)
                    .cast<String, dynamic>();
                return _buildLiveAstroCard(astro);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveAstroCard(Map<String, dynamic> astro) {
    // Backend now returns flattened: name, profile_pic, thumbnail
    final name = astro['name']?.toString().trim().isNotEmpty == true
        ? astro['name'].toString()
        : (astro['personal_details'] is Map
            ? astro['personal_details']['name']?.toString() ?? 'Astrologer'
            : 'Astrologer');

    // Use live stream thumbnail first, fall back to profile_pic
    final thumbnail = astro['thumbnail']?.toString() ?? '';
    final profilePic = astro['profile_pic']?.toString() ?? '';
    final imageUrl = thumbnail.isNotEmpty ? thumbnail : profilePic;

    final streamId = astro['_id']?.toString() ?? '';

    return SizedBox(
      width: 150.w,
      child: GestureDetector(
        onTap: () async {
          if (streamId.isEmpty) return;
          final liveController = Get.find<LiveController>();
          final joinData = await liveController.joinStream(streamId);
          if (joinData != null) {
            Get.toNamed(
              AppRoutes.liveViewer,
              arguments: {'stream': astro, 'join': joinData},
            );
          }
        },
        child: PremiumCard(
          margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
          padding: EdgeInsets.zero,
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24.r),
                child: imageUrl.isNotEmpty
                    ? Image.network(
                        ApiConstants.resolveImage(imageUrl),
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.primary.withValues(alpha: 0.1),
                        ),
                      )
                    : Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24.r),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 12.h,
                left: 12.w,
                right: 12.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      GujaratiScriptUtils.toGujaratiName(name),
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'live_now'.tr,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white70,
                        fontSize: 9.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopAstrologersSection() {
    if (controller.topAstrologers.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'top_astrologers'.tr,
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.astrologerList),
                child: Text(
                  'view_all'.tr,
                  style: AppTextStyles.buttonSmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...controller.topAstrologers.map(
            (astro) => _buildAstrologerRow(astro as Map<String, dynamic>),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologerRow(Map<String, dynamic> astro) {
    final profilePic = (astro['profilePic'] ?? astro['profile_pic'] ?? astro['profile_image'] ?? (astro['personal_details'] is Map ? astro['personal_details']['profile_image'] : ''))?.toString() ?? '';
    final rating = astro['rating'] ?? 5.0;

    return PremiumCard(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30.r,
            backgroundImage: profilePic.isNotEmpty
                ? NetworkImage(ApiConstants.resolveImage(profilePic))
                : null,
            child: profilePic.isEmpty ? const Icon(Icons.person) : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AstrologerUtils.getLocalizedAstrologerName(astro),
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.gold, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$rating',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () =>
                Get.toNamed(AppRoutes.astrologerDetail, arguments: astro),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('consult'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalyzeKundaliCard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7A4A1C).withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 130.w,
            height: 130.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFFDF9),
              border: Border.all(color: const Color(0xFFE8D4B1), width: 2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD7A545).withValues(alpha: 0.18),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/kundali_sage_badge.jpg',
                width: 130.w,
                height: 130.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 40.sp),
                      SizedBox(height: 4.h),
                      Text(
                        'ANALYZE YOUR KUNDLI\nIN-DEPTH FOR FREE',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 8.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'analyze_your_kundali'.tr,
            style: AppTextStyles.h3.copyWith(
              color: const Color(0xFF1F110B),
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'analyze_kundali_desc'.tr,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.kundli),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFAF6EE),
              foregroundColor: AppColors.primary,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
                side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'experience_now'.tr,
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Icon(Icons.chevron_right, size: 18.sp, color: AppColors.primary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlogsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(
            'latest_blog'.tr,
            'latest_blog_desc'.tr,
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 250.h,
            child: Obx(() {
              final List blogList = controller.blogs.isNotEmpty
                  ? controller.blogs.toList()
                  : [
                      {
                        'title': Get.locale?.languageCode == 'gu'
                            ? 'વૈદિક કુંડળી મિલાન માટેનું માર્ગદર્શન'
                            : (Get.locale?.languageCode == 'hi'
                                ? 'वैदिक कुंडली मिलान के लिए गाइड'
                                : 'Guide to Vedic Kundali Matching'),
                        'createdAt': '2026-03-17T00:00:00.000Z',
                        'image': 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
                      },
                    ];

              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                scrollDirection: Axis.horizontal,
                itemCount: blogList.length,
                itemBuilder: (context, index) {
                  final blog = blogList[index];
                  final title = blog['title'] ?? 'astrology_insights'.tr;
                  final image = blog['image'] ?? '';
                  final imageUrl = ApiConstants.resolveImage(image);
                  String dateStr = 'Mar 17, 2026';
                  if (blog['createdAt'] != null) {
                    try {
                      final dt = DateTime.parse(blog['createdAt']);
                      dateStr = '${NameTransliterationUtils.toLocalizedNumber(dt.day)} ${_monthName(dt.month)}, ${NameTransliterationUtils.toLocalizedNumber(dt.year)}';
                    } catch (_) {}
                  }

                  return Container(
                    width: 240.w,
                    margin: EdgeInsets.only(right: 16.w),
                    child: PremiumCard(
                      onTap: () => Get.toNamed(AppRoutes.blogDetail, arguments: blog),
                      padding: EdgeInsets.zero,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                child: Image.network(
                                  imageUrl.isNotEmpty ? imageUrl : 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=600',
                                  height: 130.h,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    height: 130.h,
                                    color: AppColors.primary.withValues(alpha: 0.1),
                                    child: Icon(Icons.article_outlined, color: AppColors.primary, size: 36.sp),
                                  ),
                                ),
                              ),
                              Positioned(
                                top: 10.h,
                                left: 10.w,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12.r),
                                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                  ),
                                  child: Text(
                                    dateStr,
                                    style: TextStyle(
                                      fontSize: 10.sp,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF4A2411),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: EdgeInsets.all(12.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 10.h),
                                Row(
                                  children: [
                                    Text(
                                      'read_more'.tr.toUpperCase(),
                                      style: TextStyle(
                                        color: const Color(0xFF8C4B1F),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11.sp,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    Icon(Icons.chevron_right, size: 14.sp, color: const Color(0xFF8C4B1F)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildWhatIsAstrologySection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFE8D4B1).withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('what_is_astrology'.tr, null),
          SizedBox(height: 16.h),
          _buildTextSubheading('astrology_language_universe'.tr),
          _buildTextParagraph(
            'astrology_language_universe_desc'.tr,
          ),
          SizedBox(height: 16.h),
          _buildTextSubheading('astrology_predictions_benefits'.tr),
          _buildTextParagraph(
            'astrology_predictions_benefits_desc'.tr,
          ),
          SizedBox(height: 16.h),
          _buildTextSubheading('how_online_astrology_benefits'.tr),
          _buildTextParagraph(
            'how_online_astrology_benefits_desc'.tr,
          ),
          SizedBox(height: 20.h),
          Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildBenefitPill('benefit_hassle_free'.tr)),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildBenefitPill('benefit_time_saving'.tr)),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(child: _buildBenefitPill('benefit_privacy'.tr)),
                  SizedBox(width: 10.w),
                  Expanded(child: _buildBenefitPill('benefit_top_astrologers'.tr)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6EE),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE8D4B1)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6.w,
            height: 6.w,
            margin: EdgeInsets.only(top: 5.h, right: 8.w),
            decoration: const BoxDecoration(
              color: Color(0xFF8C4B1F),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A2411),
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAstrologyFaqsSection() {
    final faqs = [
      {
        'q': 'faq_q1'.tr,
        'a': 'faq_a1'.tr,
      },
      {
        'q': 'faq_q2'.tr,
        'a': 'faq_a2'.tr,
      },
      {
        'q': 'faq_q3'.tr,
        'a': 'faq_a3'.tr,
      },
      {
        'q': 'faq_q4'.tr,
        'a': 'faq_a4'.tr,
      },
      {
        'q': 'faq_q5'.tr,
        'a': 'faq_a5'.tr,
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        children: [
          _buildSectionHeader(
            'faqs_related_to_astrology'.tr,
            'faqs_subtitle'.tr,
          ),
          SizedBox(height: 16.h),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Container(
                margin: EdgeInsets.only(bottom: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18.r),
                  border: Border.all(color: const Color(0xFFE8D4B1).withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                    childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                    title: Text(
                      faq['q']!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F110B),
                      ),
                    ),
                    children: [
                      Text(
                        faq['a']!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: const Color(0x99000000),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Column(
      children: [
        Center(
          child: Column(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF1F110B),
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 6.h),
              Container(
                width: 60.w,
                height: 3.h,
                decoration: BoxDecoration(
                  color: const Color(0xFF8C4B1F),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ],
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 10.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey.shade700,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  Widget _buildTextSubheading(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.bold,
        color: const Color(0xFF1F110B),
      ),
    );
  }

  Widget _buildTextParagraph(String text) {
    return Padding(
      padding: EdgeInsets.only(top: 6.h),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.black87,
          height: 1.5,
        ),
      ),
    );
  }

  String _monthName(int month) {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'gu') {
      const months = ['જાન્યુ', 'ફેબ્રુ', 'માર્ચ', 'એપ્રિલ', 'મે', 'જૂન', 'જુલાઈ', 'ઓગસ્ટ', 'સપ્ટે', 'ઓક્ટો', 'નવે', 'ડિસે'];
      return months[(month - 1) % 12];
    } else if (lang == 'hi') {
      const months = ['जनवरी', 'फरवरी', 'मार्च', 'अप्रैल', 'मई', 'जून', 'जुलाई', 'अगस्त', 'सितंबर', 'अक्टूबर', 'नवंबर', 'दिसंबर'];
      return months[(month - 1) % 12];
    }
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[(month - 1) % 12];
  }

  Widget _buildFreeChatBanner() {
    return Obx(() {
      if (!controller.isFreeChatEligible.value) {
        return const SizedBox.shrink();
      }

      return FadeInUp(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: const Color(0xFFFFB74D),
              width: 1.5.w,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFFB74D).withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon Circle
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFFA726),
                ),
                child: Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.white,
                  size: 26.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Text Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'special_offer_free_chat'.tr.replaceAll('%s', NameTransliterationUtils.toLocalizedNumber(controller.freeChatDurationMinutes.value)),
                      style: TextStyle(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'consult_top_astrologers_free'.tr,
                      style: TextStyle(
                        color: const Color(0xFFF57C00),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              // Action Button
              ElevatedButton(
                onPressed: () {
                  if (Get.isRegistered<DashboardController>()) {
                    Get.find<DashboardController>().changeTab(1);
                  } else {
                    Get.toNamed(AppRoutes.astrologerList);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE65100),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                ),
                child: Text(
                  'chat_now'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class GlowingLiveBadge extends StatefulWidget {
  final String text;
  const GlowingLiveBadge({super.key, required this.text});

  @override
  State<GlowingLiveBadge> createState() => _GlowingLiveBadgeState();
}

class _GlowingLiveBadgeState extends State<GlowingLiveBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _animation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.red.shade600,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withValues(
                  alpha: 0.2 + (_animation.value * 0.5),
                ),
                blurRadius: 10 * _animation.value,
                spreadRadius: 2 * _animation.value,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.circle, color: Colors.white, size: 8.sp),
              SizedBox(width: 4.w),
              Text(
                widget.text,
                style: AppTextStyles.caption.copyWith(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}