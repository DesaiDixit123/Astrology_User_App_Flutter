import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';

class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final List<Color>? gradientColors;
  final double borderRadius;
  final VoidCallback? onTap;
  final bool hasShadow;
  final Border? border;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.gradientColors,
    this.borderRadius = 24,
    this.onTap,
    this.hasShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? EdgeInsets.zero,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius.r),
        gradient: gradientColors != null
            ? LinearGradient(
                colors: gradientColors!,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: gradientColors == null ? AppColors.surface : null,
        boxShadow: hasShadow ? AppColors.luxuryShadow : null,
        border: border ??
            Border.all(
              color: AppColors.borderLight,
              width: 1.5,
            ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(borderRadius.r),
          child: Padding(
            padding: padding ?? EdgeInsets.all(20.w),
            child: child,
          ),
        ),
      ),
    );
  }
}
