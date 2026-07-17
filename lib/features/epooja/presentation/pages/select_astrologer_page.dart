import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:astrology_user/features/services/data/models/puja_model.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_text_styles.dart';

import '../../../astrologers/presentation/controllers/astrologer_controller.dart';
import './puja_checkout_page.dart';
import '../widgets/puja_booking_flow_dialogs.dart';

class SelectAstrologerPage extends StatefulWidget {
  final Puja puja;
  final PujaPackage package;

  const SelectAstrologerPage({
    super.key,
    required this.puja,
    required this.package,
  });

  @override
  State<SelectAstrologerPage> createState() => _SelectAstrologerPageState();
}

class _SelectAstrologerPageState extends State<SelectAstrologerPage> {
  final astrologerController = Get.find<AstrologerController>();
  final pujaController = Get.find<PujaController>();
  final TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    astrologerController.loadAstrologers(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2), // Light cream as in image
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Select Astrologer',
          style: AppTextStyles.h1.copyWith(
            color: const Color(0xFF1A1A1A),
            fontWeight: FontWeight.w900,
            fontSize: 28.sp,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(),
          Expanded(
            child: Obx(() {
              if (astrologerController.isLoading.value &&
                  astrologerController.astrologers.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (astrologerController.astrologers.isEmpty) {
                return const Center(child: Text('No astrologers found'));
              }

              return ListView.builder(
                padding: EdgeInsets.all(20.w),
                itemCount: astrologerController.astrologers.length,
                itemBuilder: (context, index) {
                  final astrologer = astrologerController.astrologers[index];
                  return _buildAstrologerCard(astrologer);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30.r),
          bottomRight: Radius.circular(30.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: TextField(
              controller: searchController,
              onChanged: (value) => astrologerController.search(value),
              decoration: InputDecoration(
                hintText: 'Search Astrologer',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15.h),
              ),
            ),
          ),
          SizedBox(height: 15.h),
          Row(
            children: [
              _filterDropdown('Sort Filter'),
              SizedBox(width: 10.w),
              _filterDropdown('All'),
              SizedBox(width: 10.w),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E2633),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown(String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.bodySmall),
            const Icon(Icons.keyboard_arrow_down, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _buildAstrologerCard(Map<String, dynamic> astrologer) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(15.w),
            child: Row(
              children: [
                _buildProfileImage(astrologer),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        astrologer['name']?.toString().toUpperCase() ?? 'UNKNOWN',
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w900,
                          fontSize: 14.sp,
                          color: const Color(0xFF1E2633),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.h),
                      _bioRow(Icons.school_outlined, astrologer['skills']?[0] ?? 'test'),
                      _bioRow(Icons.language_outlined, astrologer['languages']?[0] ?? 'Gujarati'),
                      _bioRow(Icons.work_outline, 'Exp: ${astrologer['experience'] ?? 0} Years'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
            child: Row(
              children: [
                _ratingBlock(astrologer['rating'] ?? '4.9'),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    '${astrologer['totalConsultations'] ?? 7} SESSIONS',
                    style: AppTextStyles.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF94A3B8),
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildSelectButton(astrologer),
        ],
      ),
    );
  }

  Widget _bioRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        children: [
          Icon(icon, size: 10.sp, color: const Color(0xFF64748B)),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.caption.copyWith(
                fontSize: 10.sp,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ratingBlock(dynamic rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              rating.toString(),
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12.sp,
                color: const Color(0xFF1E2633),
              ),
            ),
            SizedBox(width: 4.w),
            Row(
              children: List.generate(
                4,
                (_) => Icon(Icons.star, color: Colors.orange, size: 10.sp),
              ) +
                  [Icon(Icons.star_border, color: Colors.grey, size: 10.sp)],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectButton(Map<String, dynamic> astrologer) {
    return InkWell(
      onTap: () => _handleSelect(astrologer),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: const Color(0xFF1E2633),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(25.r),
            bottomRight: Radius.circular(25.r),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white, size: 14.sp),
            SizedBox(width: 8.w),
            Text(
              'SELECT',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12.sp,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileImage(Map<String, dynamic> astrologer) {
    final imageUrl = astrologer['profilePic'];
    return Stack(
      children: [
        Container(
          width: 60.w,
          height: 60.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF1A1A1A), width: 1.5),
            image: DecorationImage(
              image: NetworkImage(
                imageUrl != null && imageUrl.toString().isNotEmpty
                    ? (imageUrl.toString().startsWith('http')
                        ? imageUrl.toString()
                        : '${ApiConstants.imageBaseUrl}/$imageUrl')
                    : 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 12.w,
            height: 12.w,
            decoration: BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSelect(Map<String, dynamic> astrologer) {
    Get.dialog(
      PujaModeDialog(
        onModeSelected: (mode) {
          Get.back(); // Close dialog
          Get.to(
            () => PujaCheckoutPage(
              puja: widget.puja,
              package: widget.package,
              astrologer: astrologer,
              mode: mode,
            ),
          );
        },
      ),
    );
  }
}
