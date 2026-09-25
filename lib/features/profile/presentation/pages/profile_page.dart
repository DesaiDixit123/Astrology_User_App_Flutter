import 'package:animate_do/animate_do.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/core/utils/gujarati_script_utils.dart';
import 'package:astrology_user/shared/widgets/premium_card.dart';
import 'package:astrology_user/features/astrologers/presentation/pages/following_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../controllers/profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => controller.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : CustomScrollView(
                slivers: [
                  _buildSliverAppBar(),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.w),
                      child: Column(
                        children: [
                          SizedBox(height: 20.h),
                          FadeInUp(child: _buildWalletCard()),
                          SizedBox(height: 24.h),
                          FadeInUp(
                            delay: const Duration(milliseconds: 200),
                            child: _buildMenuSection(),
                          ),
                          SizedBox(height: 120.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 240.h,
      pinned: true,
      backgroundColor: AppColors.deepCosmic,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: AppColors.cosmicGradient,
              ),
            ),
            Positioned(
              top: 60.h,
              child: GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.editProfile),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: AppColors.goldenGradient,
                          ),
                          child: CircleAvatar(
                            radius: 50.r,
                            backgroundColor: Colors.white,
                            backgroundImage:
                                controller.profileImageUrl.isNotEmpty
                                ? NetworkImage(controller.profileImageUrl)
                                : null,
                            child: controller.profileImageUrl.isEmpty
                                ? Icon(
                                    Icons.person,
                                    size: 50.sp,
                                    color: AppColors.primary,
                                  )
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.camera_alt,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      GujaratiScriptUtils.toGujaratiName(controller.userData['name']?.toString() ?? 'user'.tr),
                      style: AppTextStyles.displayMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      controller.phoneController.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          onPressed: () => Get.toNamed(AppRoutes.settings),
        ),
      ],
    );
  }

  Widget _buildWalletCard() {
    return PremiumCard(
      padding: EdgeInsets.all(20.w),
      gradientColors: [const Color(0xFF141E30), const Color(0xFF243B55)],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'wallet_balance'.tr,
                style: AppTextStyles.caption.copyWith(color: Colors.white70),
              ),
              SizedBox(height: 4.h),
              Obx(() {
                final walletController = Get.find<WalletController>();
                return Text(
                  '₹${walletController.walletBalance.value.toStringAsFixed(2)}',
                  style: AppTextStyles.h2.copyWith(color: AppColors.gold),
                );
              }),
            ],
          ),
          ElevatedButton(
            onPressed: () => Get.toNamed(AppRoutes.wallet),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text('recharge'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Column(
      children: [
        _buildMenuItem(
          Icons.person_outline_rounded,
          'edit_profile'.tr,
          () => Get.toNamed(AppRoutes.editProfile),
        ),
        _buildMenuItem(
          Icons.history_rounded,
          'order_history'.tr,
          () => Get.toNamed(AppRoutes.orders),
        ),
        _buildMenuItem(
          Icons.shopping_bag_outlined,
          'shop_orders'.tr,
          () => Get.toNamed(AppRoutes.shopOrders),
        ),
        _buildMenuItem(
          Icons.temple_hindu_outlined,
          'my_puja_orders'.tr,
          () => Get.toNamed(AppRoutes.pujaHistory),
        ),
        _buildMenuItem(
          Icons.receipt_long_outlined,
          'transactions'.tr,
          () => Get.toNamed(AppRoutes.transactions),
        ),
        _buildMenuItem(
          Icons.favorite_rounded,
          'my_following'.tr,
          () => Get.to(() => const FollowingPage()),
        ),
        _buildMenuItem(
          Icons.help_outline_rounded,
          'help_support'.tr,
          () => Get.toNamed(AppRoutes.help),
        ),
        _buildMenuItem(
          Icons.logout_rounded,
          'logout'.tr,
          controller.logout,
          isDestructive: true,
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return PremiumCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isDestructive
                  ? Colors.red.withValues(alpha: 0.1)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: isDestructive ? Colors.red : AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: isDestructive ? Colors.red : AppColors.textPrimary,
              ),
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: AppColors.textHint,
            size: 20.sp,
          ),
        ],
      ),
    );
  }
}
