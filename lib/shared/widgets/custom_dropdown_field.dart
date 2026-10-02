import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class CustomDropdownField<T> extends StatelessWidget {
  final String? labelText;
  final String hintText;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final IconData? prefixIcon;

  const CustomDropdownField({
    super.key,
    this.labelText,
    required this.hintText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    // Case-insensitive or direct match to prevent Flutter assertion crash when value is not in items
    final matchedItem = items.cast<DropdownMenuItem<T>?>().firstWhere(
          (item) =>
              item?.value == value ||
              (value is String &&
                  item?.value is String &&
                  (item!.value as String).toLowerCase() ==
                      (value as String).toLowerCase()),
          orElse: () => null,
        );
    final T? effectiveValue = matchedItem?.value;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(labelText!, style: AppTextStyles.label),
          SizedBox(height: 8.h),
        ],
        DropdownButtonFormField<T>(
          value: effectiveValue,
          items: items,
          onChanged: onChanged,
          isExpanded: true,
          isDense: true,
          dropdownColor: AppColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary,
            size: 22.sp,
          ),
          style: AppTextStyles.bodyMedium,
          hint: Text(
            hintText,
            style: AppTextStyles.hint,
            overflow: TextOverflow.ellipsis,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.textSecondary, size: 20.sp)
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16.w,
              vertical: 14.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.textHint, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.textHint, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
