import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:astrology_user/shared/widgets/glass_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
                    if (controller.liveAstrologers.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 400),
                        child: _buildLiveAstrologersSection(),
                      ),
                    if (controller.topAstrologers.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 600),
                        child: _buildTopAstrologersSection(),
                      ),
                    if (controller.blogs.isNotEmpty)
                      FadeInUp(
                        delay: const Duration(milliseconds: 800),
                        child: _buildBlogsSection(),
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
              'Vedikvani',
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
                final isAsset = banner['isAsset'] == true;
                final imagePath = banner['image'];

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
    // NOTE: Kundli, Horoscope, Matchmaking and Panchang are temporarily hidden
    // for App Store review (Apple Guideline 4.3 — saturated category).
    // They will be restored in the next update after approval.
    final services = [
      {
        'icon': Icons.shopping_bag_outlined,
        'label': 'e_shop_title'.tr,
        'route': AppRoutes.shop,
        'color': [const Color(0xFF6E4A22), const Color(0xFFC89647)],
      },
      {
        'icon': Icons.temple_hindu,
        'label': 'e_pooja_title'.tr,
        'route': '/e-pooja',
        'color': [const Color(0xFF8A251B), const Color(0xFFB73716)],
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Services',
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
                      name,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Live now',
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
    final name = astro['name']?.toString() ?? 'Astrologer';
    final profilePic = astro['profilePic']?.toString() ?? '';
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
                  name,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.star, color: AppColors.gold, size: 14.sp),
                    SizedBox(width: 4.w),
                    Text(
                      '$rating',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.bold,
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

  Widget _buildBlogsSection() {
    if (controller.blogs.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'astrology_insights'.tr,
                style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w800),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoutes.blogs),
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
          SizedBox(
            height: 220.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: controller.blogs.length,
              itemBuilder: (context, index) {
                final blog = controller.blogs[index];
                final title = blog['title'] ?? 'Title';
                final image = blog['image'] ?? '';
                final imageUrl = ApiConstants.resolveImage(image);

                return SizedBox(
                  width: 260.w,
                  child: PremiumCard(
                    onTap: () =>
                        Get.toNamed(AppRoutes.blogDetail, arguments: blog),
                    margin: EdgeInsets.only(right: 16.w, bottom: 8.h),
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(24.r),
                          ),
                          child: Image.network(
                            imageUrl,
                            height: 130.h,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 130.h,
                                  width: double.infinity,
                                  color: AppColors.primary.withValues(
                                    alpha: 0.1,
                                  ),
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.primary,
                                    size: 30.sp,
                                  ),
                                ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(12.w),
                          child: Text(
                            title,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
                      'Special Offer: ${controller.freeChatDurationMinutes.value} Min Free Chat!',
                      style: TextStyle(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Consult top astrologers for free. Offer ends soon!',
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
                  'Chat Now',
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