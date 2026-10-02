import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  static const String supportPhone = '9904755099';
  static const String supportEmail = 'support@vedikvani.com';

  Future<void> _makePhoneCall() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: supportPhone);
    try {
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        _copyToClipboard(supportPhone, 'Phone number copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(supportPhone, 'Phone number copied to clipboard');
    }
  }

  Future<void> _sendEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: supportEmail,
      queryParameters: {'subject': 'Vedikvani Support Request'},
    );
    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        _copyToClipboard(supportEmail, 'Support email copied to clipboard');
      }
    } catch (_) {
      _copyToClipboard(supportEmail, 'Support email copied to clipboard');
    }
  }

  void _copyToClipboard(String text, String message) {
    Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      'Copied',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('help_support'.tr),
        elevation: 0,
      ),
      body: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          _buildHeaderCard(),
          SizedBox(height: 16.h),
          _buildContactDetailCard(
            icon: Icons.phone_in_talk_rounded,
            title: 'Call Support',
            value: '+91 $supportPhone',
            actionLabel: 'Call Now',
            color: const Color(0xFF2E7D32),
            onTap: _makePhoneCall,
          ),
          SizedBox(height: 12.h),
          _buildContactDetailCard(
            icon: Icons.mark_email_read_rounded,
            title: 'Email Support',
            value: supportEmail,
            actionLabel: 'Send Email',
            color: const Color(0xFFC62828),
            onTap: _sendEmail,
          ),
          SizedBox(height: 24.h),
          _buildFAQSection(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.support_agent_rounded, size: 44.sp, color: Colors.white),
          ),
          SizedBox(height: 12.h),
          Text(
            'Need Help & Support?',
            style: AppTextStyles.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 6.h),
          Text(
            'Our dedicated customer care team is available to assist you.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildContactDetailCard({
    required IconData icon,
    required String title,
    required String value,
    required String actionLabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: color, size: 26.sp),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: const Color(0xFF1F110B),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.r),
              ),
            ),
            child: Text(
              actionLabel,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
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
            'Browse astrologers, select your preferred one, choose consultation type (Call/Chat/Video), and proceed to consultation.',
      },
      {
        'question': 'How do I recharge my wallet?',
        'answer':
            'Go to Profile > Wallet > Add Money, select your amount, and complete payment using UPI, NetBanking, or Cards.',
      },
      {
        'question': 'How can I contact customer support?',
        'answer':
            'You can call us directly at +91 9904755099 or email us at support@vedikvani.com.',
      },
      {
        'question': 'Are my consultations private?',
        'answer':
            'Yes, all consultations are 100% private, safe, and confidential.',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        ...faqs.map((faq) => _buildFAQCard(faq)).toList(),
      ],
    );
  }

  Widget _buildFAQCard(Map faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.textHint.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: ThemeData(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
          childrenPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
          title: Text(
            faq['question']!,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 13.sp,
            ),
          ),
          children: [
            Text(
              faq['answer']!,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
