import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class PujaModeDialog extends StatelessWidget {
  final Function(String) onModeSelected;

  const PujaModeDialog({super.key, required this.onModeSelected});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Puja Mode',
              style: AppTextStyles.h4.copyWith(color: AppColors.primary),
            ),
            SizedBox(height: 20.h),
            _buildModeOption(
              icon: Icons.personal_video_rounded,
              title: 'Online Puja',
              subtitle: 'Join via video call and receive digital prasad.',
              mode: 'online',
            ),
            SizedBox(height: 15.h),
            _buildModeOption(
              icon: Icons.temple_hindu_rounded,
              title: 'Offline Puja',
              subtitle: 'Ritual performed at temple, prasad via courier.',
              mode: 'offline',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required String mode,
  }) {
    return InkWell(
      onTap: () => onModeSelected(mode),
      borderRadius: BorderRadius.circular(15.r),
      child: Container(
        padding: EdgeInsets.all(15.w),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.primary, size: 24.sp),
            ),
            SizedBox(width: 15.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold)),
                  Text(subtitle, style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
