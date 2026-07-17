import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Display Styles
  static TextStyle displayLarge = GoogleFonts.cormorantGaramond(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle displayMedium = GoogleFonts.cormorantGaramond(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  // Headings
  static TextStyle h1 = GoogleFonts.cormorantGaramond(
    fontSize: 32.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle h2 = GoogleFonts.cormorantGaramond(
    fontSize: 28.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.2,
  );

  static TextStyle h3 = GoogleFonts.cormorantGaramond(
    fontSize: 24.sp,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  static TextStyle h4 = GoogleFonts.cormorantGaramond(
    fontSize: 20.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: 0.15,
  );

  // Body Text
  static TextStyle bodyLarge = GoogleFonts.manrope(
    fontSize: 16.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle bodySmall = GoogleFonts.manrope(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.3,
  );

  // Button Text
  static TextStyle button = GoogleFonts.manrope(
    fontSize: 16.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.35,
  );

  static TextStyle buttonSmall = GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
  );

  // Caption & Labels
  static TextStyle caption = GoogleFonts.manrope(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static TextStyle label = GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static TextStyle hint = GoogleFonts.manrope(
    fontSize: 14.sp,
    fontWeight: FontWeight.w500,
    color: AppColors.textHint,
  );
}
