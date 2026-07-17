import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/service_controller.dart';

class HoroscopeDetailPage extends StatefulWidget {
  const HoroscopeDetailPage({super.key});

  @override
  State<HoroscopeDetailPage> createState() => _HoroscopeDetailPageState();
}

class _HoroscopeDetailPageState extends State<HoroscopeDetailPage> {
  late final ServiceController controller;
  late final Map<String, dynamic> sign;
  late final String requestName;
  String _selectedType = 'daily';
  bool _isLoading = true;
  bool _hasError = false;
  Map<String, dynamic> _result = {};

  @override
  void initState() {
    super.initState();
    controller = Get.find<ServiceController>();
    final args = Get.arguments;
    sign = args is Map ? Map<String, dynamic>.from(args) : <String, dynamic>{};
    requestName =
        sign['canonical_name']?.toString() ??
        sign['sign_name']?.toString() ??
        '';
    _loadHoroscope();
  }

  @override
  Widget build(BuildContext context) {
    final signName = sign['sign_name']?.toString() ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          signName.isEmpty
              ? 'horoscope_title'.tr
              : '$signName ${'horoscope_suffix'.tr}',
        ),
      ),
      body: _buildBody(signName),
    );
  }

  Widget _buildBody(String signName) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError || _result.isEmpty) {
      return _buildErrorState();
    }

    final signDetails =
        (_result['sign_details'] as Map?)?.cast<String, dynamic>() ?? sign;
    final prediction =
        (_result['prediction'] as Map?)?.cast<String, dynamic>() ?? {};
    final horoscopeText = _firstNonEmpty([
      prediction['prediction'],
      prediction['response'],
      _result['bot_response'],
    ]);

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24.r),
            child: SizedBox(
              width: double.infinity,
              height: 220.h,
              child: Image.network(
                ApiConstants.resolveImage(
                  signDetails['sign_image']?.toString() ?? '',
                ),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: AppColors.parchmentGradient,
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.auto_awesome,
                      size: 56.sp,
                      color: AppColors.primary,
                    ),
                  );
                },
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            signDetails['sign_name']?.toString() ?? signName,
            style: AppTextStyles.h2,
          ),
          SizedBox(height: 8.h),
          if ((signDetails['description']?.toString() ?? '').isNotEmpty)
            Text(
              signDetails['description'].toString(),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          SizedBox(height: 20.h),
          Wrap(
            spacing: 10.w,
            runSpacing: 10.h,
            children: [
              _buildTypeChip('daily'),
              _buildTypeChip('weekly'),
              _buildTypeChip('yearly'),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(18.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: AppColors.shadow,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_horoscopeTitle(_selectedType), style: AppTextStyles.h4),
                SizedBox(height: 12.h),
                Text(
                  horoscopeText.isNotEmpty
                      ? horoscopeText
                      : 'Prediction not available right now.',
                  style: AppTextStyles.bodyMedium.copyWith(height: 1.6),
                ),
              ],
            ),
          ),
          if ((prediction['lucky_color']?.toString() ?? '').isNotEmpty ||
              (prediction['lucky_number']?.toString() ?? '').isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: 18.h),
              child: Wrap(
                spacing: 10.w,
                runSpacing: 10.h,
                children: [
                  if ((prediction['lucky_color']?.toString() ?? '').isNotEmpty)
                    _buildInfoChip(
                      label: 'Lucky Color',
                      value: prediction['lucky_color'].toString(),
                    ),
                  if ((prediction['lucky_number']?.toString() ?? '').isNotEmpty)
                    _buildInfoChip(
                      label: 'Lucky Number',
                      value: prediction['lucky_number'].toString(),
                    ),
                ],
              ),
            ),
          SizedBox(height: 24.h),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 44.sp,
              color: AppColors.textHint,
            ),
            SizedBox(height: 12.h),
            Text(
              'Unable to load horoscope details.',
              style: AppTextStyles.bodyLarge,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: _loadHoroscope,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final isSelected = _selectedType == type;
    return GestureDetector(
      onTap: isSelected ? null : () => _changeType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          _typeLabel(type),
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({required String label, required String value}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryLight.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            TextSpan(
              text: value,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeType(String type) async {
    setState(() {
      _selectedType = type;
    });
    await _loadHoroscope();
  }

  Future<void> _loadHoroscope() async {
    if (requestName.isEmpty) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _hasError = true;
        _result = {};
      });
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }

    final success = await controller.getHoroscope(
      requestName,
      type: _selectedType,
    );

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _hasError = !success || controller.horoscopeResult.isEmpty;
      _result = success
          ? Map<String, dynamic>.from(controller.horoscopeResult)
          : {};
    });
  }

  String _horoscopeTitle(String type) {
    switch (type) {
      case 'weekly':
        return 'Weekly Horoscope';
      case 'yearly':
        return 'Yearly Horoscope';
      default:
        return 'daily_horoscope'.tr;
    }
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'weekly':
        return 'Weekly';
      case 'yearly':
        return 'Yearly';
      default:
        return 'Daily';
    }
  }

  String _firstNonEmpty(List<dynamic> values) {
    for (final value in values) {
      final text = value?.toString().trim() ?? '';
      if (text.isNotEmpty) {
        return text;
      }
    }
    return '';
  }
}
