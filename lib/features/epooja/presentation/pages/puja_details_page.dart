import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import 'package:astrology_user/features/services/data/models/puja_model.dart';
import './select_astrologer_page.dart';

class PujaDetailsPage extends StatefulWidget {
  final String pujaId;

  const PujaDetailsPage({super.key, required this.pujaId});

  @override
  State<PujaDetailsPage> createState() => _PujaDetailsPageState();
}

class _PujaDetailsPageState extends State<PujaDetailsPage> with SingleTickerProviderStateMixin {
  final controller = Get.find<PujaController>();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPujaDetails(widget.pujaId);
      controller.getPujaFaqs();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value && controller.pujaDetail.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final puja = controller.pujaDetail.value;
        if (puja == null) {
          return const Center(child: Text('Puja details not found'));
        }

        return Stack(
          children: [
            NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  _buildSliverAppBar(puja),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverTabDelegate(
                      TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        labelColor: AppColors.primary,
                        unselectedLabelColor: AppColors.textSecondary,
                        indicatorColor: AppColors.primary,
                        indicatorWeight: 3,
                        labelStyle: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
                        tabs: const [
                          Tab(text: 'About Puja'),
                          Tab(text: 'Benefits'),
                          Tab(text: 'Process'),
                          Tab(text: 'Packages'),
                          Tab(text: 'FAQs'),
                        ],
                      ),
                    ),
                  ),
                ];
              },
              body: TabBarView(
                controller: _tabController,
                children: [
                  _buildAboutTab(puja),
                  _buildBenefitsTab(puja),
                  _buildProcessTab(puja),
                  _buildPackagesTab(puja),
                  _buildFaqsTab(),
                ],
              ),
            ),
            _buildStickyFooter(),
          ],
        );
      }),
    );
  }

  Widget _buildSliverAppBar(Puja puja) {
    return SliverAppBar(
      expandedHeight: 280.h,
      pinned: true,
      elevation: 0,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: puja.id,
              child: puja.fullImageUrl.isNotEmpty
                  ? Image.network(puja.fullImageUrl, fit: BoxFit.cover)
                  : Container(color: AppColors.primary.withOpacity(0.2)),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.4), Colors.transparent, Colors.black.withOpacity(0.4)],
                ),
              ),
            ),
            Positioned(
              bottom: 20.h,
              left: 20.w,
              right: 20.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    puja.title,
                    style: AppTextStyles.h2.copyWith(color: Colors.white),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    puja.subtitle,
                    style: AppTextStyles.bodyMedium.copyWith(color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutTab(Puja puja) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('About ${puja.title}', style: AppTextStyles.h4),
          SizedBox(height: 12.h),
          Text(
            puja.about,
            style: AppTextStyles.bodyMedium.copyWith(height: 1.6, color: AppColors.textPrimary),
          ),
          SizedBox(height: 80.h), // Spacing for footer
        ],
      ),
    );
  }

  Widget _buildBenefitsTab(Puja puja) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: puja.benefits.length,
      itemBuilder: (context, index) {
        final benefit = puja.benefits[index];
        return Container(
          margin: EdgeInsets.only(bottom: 15.h),
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.orange[50]!.withOpacity(0.3),
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: Colors.orange[100]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.auto_awesome, color: AppColors.primary, size: 20.sp),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(benefit.title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    SizedBox(height: 4.h),
                    Text(benefit.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProcessTab(Puja puja) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How it works', style: AppTextStyles.h4),
          SizedBox(height: 20.h),
          _buildProcessStep(1, 'Select Package', 'Choose the package that suits your needs.'),
          _buildProcessStep(2, 'Select Astrologer', 'Pick an experienced astrologer to perform the ritual.'),
          _buildProcessStep(3, 'Provide Details', 'Share your Name, Gotra (optional), and Sankalpa.'),
          _buildProcessStep(4, 'Puja Performance', 'The ritual is performed on the selected date.'),
          _buildProcessStep(5, 'Direct Blessing', 'Receive the video and digital prasad (for Online).'),
        ],
      ),
    );
  }

  Widget _buildProcessStep(int step, String title, String desc) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35.w,
            height: 35.w,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: Center(child: Text('$step', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          SizedBox(width: 15.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                Text(desc, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackagesTab(Puja puja) {
    return ListView.builder(
      padding: EdgeInsets.all(20.w),
      itemCount: puja.packages.length,
      itemBuilder: (context, index) {
        final package = puja.packages[index];
        return Container(
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: AppColors.luxuryShadow,
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(15.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(package.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold))),
                    Text('₹${package.priceInr}', style: AppTextStyles.h4.copyWith(color: AppColors.primary)),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(15.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(package.description, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    SizedBox(height: 15.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleParticipate(package),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                        ),
                        child: const Text('PARTICIPATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFaqsTab() {
    return Obx(() {
      if (controller.faqs.isEmpty) return const Center(child: Text('No FAQs available'));
      return ListView.builder(
        padding: EdgeInsets.all(20.w),
        itemCount: controller.faqs.length,
        itemBuilder: (context, index) {
          final faq = controller.faqs[index];
          return ExpansionTile(
            title: Text(faq['question'] ?? '', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
                child: Text(faq['answer'] ?? '', style: AppTextStyles.bodySmall),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildStickyFooter() {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return Positioned(
      bottom: bottomInset + 16.h,
      left: 20.w,
      right: 20.w,
      child: ElevatedButton(
        onPressed: () {
          _tabController.animateTo(3); // Go to Packages tab
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4A2C2A), // Dark brown as in image
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          elevation: 8,
        ),
        child: Text(
          'SELECT PUJA PACKAGE',
          style: AppTextStyles.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _handleParticipate(PujaPackage package) {
    Get.to(() => SelectAstrologerPage(puja: controller.pujaDetail.value!, package: package));
  }
}

class _SliverTabDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabDelegate oldDelegate) {
    return false;
  }
}
