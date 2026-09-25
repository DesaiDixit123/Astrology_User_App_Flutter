import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class TermsPage extends StatelessWidget {
  const TermsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('terms_conditions'.tr),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.gavel_rounded, color: AppColors.primary, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Vedikvani Terms & Conditions',
                      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildSection(
              title: '1. Acceptance of Terms',
              content:
                  'By downloading, accessing, or using the Vedikvani application, you agree to be bound by these Terms & Conditions. If you do not agree with any part of these terms, you must discontinue using the app immediately.',
            ),
            _buildSection(
              title: '2. Astrological Guidance Disclaimer',
              content:
                  'All astrological consultations, Kundli predictions, daily horoscopes, and Panchang readings provided on Vedikvani are intended solely for spiritual guidance, personal growth, and self-discovery. Predictions are based on traditional Vedic principles and should not replace professional medical, legal, financial, or psychological advice.',
            ),
            _buildSection(
              title: '3. Consultations & Wallet Billing',
              content:
                  'Live consultations with spiritual guides and astrologers are charged on a per-minute basis. Wallet balances are non-refundable once deducted for active chat, voice, or video consultation sessions.',
            ),
            _buildSection(
              title: '4. E-Pooja & Astro E-Shop Orders',
              content:
                  'Virtual Puja rituals and physical astro products (Gemstones, Rudraksha, Yantras) are processed upon successful booking. Dispatch of Prasad or products will be sent to the shipping address provided at checkout.',
            ),
            _buildSection(
              title: '5. Account Security & Conduct',
              content:
                  'Users are responsible for maintaining the confidentiality of their mobile OTP, login credentials, and personal details. Any abusive behavior towards spiritual guides will result in immediate account suspension.',
            ),
            _buildSection(
              title: '6. Modification of Terms',
              content:
                  'Vedikvani reserves the right to update these terms at any time. Continued use of the platform following modifications constitutes acceptance of the revised terms.',
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            content,
            style: AppTextStyles.bodySmall.copyWith(
              height: 1.5,
              fontSize: 13.sp,
            ),
          ),
        ],
      ),
    );
  }
}
