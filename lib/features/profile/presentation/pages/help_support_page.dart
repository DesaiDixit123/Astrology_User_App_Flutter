import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Help & Support')),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildContactCard(),
          SizedBox(height: 24.h),
          _buildFAQSection(),
        ],
      ),
    );
  }

  Widget _buildContactCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.support_agent, size: 48.sp, color: Colors.white),
          SizedBox(height: 16.h),
          Text(
            'Need Help?',
            style: AppTextStyles.h3.copyWith(color: Colors.white),
          ),
          SizedBox(height: 8.h),
          Text(
            'Our support team is here to help you 24/7',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.phone),
                  label: const Text('Call Us'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email),
                  label: const Text('Email Us'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      {
        'question': 'How do I book a consultation?',
        'answer':
            'Browse astrologers, select your preferred one, choose consultation type (Call/Chat/Video), and proceed to payment.',
      },
      {
        'question': 'How do I recharge my wallet?',
        'answer':
            'Go to Profile > Wallet > Recharge, select amount, and complete payment using your preferred method.',
      },
      {
        'question': 'Can I get a refund?',
        'answer':
            'Refunds are processed within 5-7 business days if the consultation was not completed due to technical issues.',
      },
      {
        'question': 'How do I change my profile details?',
        'answer':
            'Go to Profile > Edit Profile to update your name, email, date of birth, and other details.',
      },
      {
        'question': 'Are my consultations private?',
        'answer':
            'Yes, all consultations are completely private and confidential. We use end-to-end encryption.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Frequently Asked Questions', style: AppTextStyles.h4),
        SizedBox(height: 16.h),
        ...faqs.map((faq) => _buildFAQCard(faq)).toList(),
      ],
    );
  }

  Widget _buildFAQCard(Map faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.textHint),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
          title: Text(
            faq['question']!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Text(
              faq['answer']!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
