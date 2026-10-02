import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/shared/widgets/premium_nav.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../live/presentation/pages/live_tab_page.dart';
import '../../../astrologers/presentation/pages/astrologer_list_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../chat/presentation/pages/chat_history_page.dart';
import '../controllers/dashboard_controller.dart';

class DashboardPage extends GetView<DashboardController> {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const HomePage(),
      const AstrologerListPage(),
      const LiveTabPage(),
      const ChatHistoryPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      extendBody: true, // Crucial for floating navbar
      backgroundColor: AppColors.background,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: pages,
        ),
      ),
      bottomNavigationBar: Obx(
        () => PremiumBottomNav(
          currentIndex: controller.currentIndex.value,
          onTap: (index) => controller.changeTab(index),
          items: [
            PremiumNavItem(
              icon: Icons.home_outlined,
              activeIcon: Icons.home_rounded,
              label: 'home'.tr,
            ),
            PremiumNavItem(
              icon: Icons.person_search_outlined,
              activeIcon: Icons.person_search_rounded,
              label: 'astrologer'.tr,
            ),
            PremiumNavItem(
              icon: Icons.live_tv_outlined,
              activeIcon: Icons.live_tv_rounded,
              label: 'live'.tr,
            ),
            PremiumNavItem(
              icon: Icons.history_outlined,
              activeIcon: Icons.history_rounded,
              label: 'history'.tr,
            ),
            PremiumNavItem(
              icon: Icons.person_outline,
              activeIcon: Icons.person_rounded,
              label: 'profile'.tr,
            ),
          ],
        ),
      ),
    );
  }
}
