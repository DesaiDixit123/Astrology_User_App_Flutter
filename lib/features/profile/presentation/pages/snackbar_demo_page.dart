import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/core/utils/snackbar_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SnackbarDemoPage extends StatelessWidget {
  const SnackbarDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snackbar Demo')),
      body: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Try Different Snackbar Types',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40.h),
            _buildDemoButton(
              'Success Snackbar',
              AppColors.success,
              () => SnackbarUtil.success('Operation completed successfully!'),
            ),
            SizedBox(height: 16.h),
            _buildDemoButton(
              'Error Snackbar',
              AppColors.error,
              () =>
                  SnackbarUtil.error('Something went wrong. Please try again.'),
            ),
            SizedBox(height: 16.h),
            _buildDemoButton(
              'Warning Snackbar',
              AppColors.warning,
              () =>
                  SnackbarUtil.warning('Your session will expire in 5 minutes'),
            ),
            SizedBox(height: 16.h),
            _buildDemoButton(
              'Info Snackbar',
              AppColors.info,
              () => SnackbarUtil.info('New features are now available!'),
            ),
            SizedBox(height: 32.h),
            Divider(color: AppColors.border),
            SizedBox(height: 32.h),
            Text(
              'Custom Examples',
              style: AppTextStyles.h3,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            _buildDemoButton(
              'Custom Title',
              AppColors.primary,
              () => SnackbarUtil.success(
                'Your profile has been updated with new information',
                title: 'Profile Updated',
              ),
            ),
            SizedBox(height: 16.h),
            _buildDemoButton(
              'Long Duration (5s)',
              AppColors.info,
              () => SnackbarUtil.show(
                message: 'This message will stay visible for 5 seconds',
                type: SnackbarType.info,
                duration: const Duration(seconds: 5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDemoButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 2,
      ),
      child: Text(
        label,
        style: AppTextStyles.bodyLarge.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
