import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('privacy_policy'.tr),
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
                  Icon(Icons.shield_outlined, color: AppColors.primary, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      'Vedikvani Privacy Policy',
                      style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            _buildSection(
              title: '1. Information We Collect',
              content:
                  'We collect personal details essential for astrological calculations, including your Full Name, Mobile Number, Date of Birth, Time of Birth, Gender, and Birth City/Location. Location inputs are processed via Nominatim / OpenStreetMap services for precise latitude and longitude calculation.',
            ),
            _buildSection(
              title: '2. How We Use Your Information',
              content:
                  'Your personal and astrological birth details are strictly used to compute Janam Kundli charts, Gun Milan compatibility scores, Panchang timings, and horoscope forecasts, as well as to facilitate live consultations with spiritual guides.',
            ),
            _buildSection(
              title: '3. Data Security & Encryption',
              content:
                  'We employ SSL encryption, secure tokens, and protected database storage to safeguard your data. Your private consultation chats and audio/video streams are kept confidential.',
            ),
            _buildSection(
              title: '4. Third-Party Services & Payments',
              content:
                  'Payment transactions for wallet recharges and store orders are processed securely via PCI-DSS compliant payment gateways (Razorpay / Stripe). Vedikvani does not store full credit/debit card numbers or net banking passwords.',
            ),
            _buildSection(
              title: '5. User Rights & Account Deletion',
              content:
                  'You have the right to inspect, update, or request the complete deletion of your Vedikvani user account and associated personal data at any time via the Settings menu.',
            ),
            _buildSection(
              title: '6. Contact Us',
              content:
                  'If you have questions or concerns regarding this Privacy Policy, please contact our support team at support@vedikvani.com.',
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
