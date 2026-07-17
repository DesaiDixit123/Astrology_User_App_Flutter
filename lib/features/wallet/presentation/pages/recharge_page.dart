import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../controllers/wallet_controller.dart';

class RechargePage extends StatefulWidget {
  const RechargePage({super.key});

  @override
  State<RechargePage> createState() => _RechargePageState();
}

class _RechargePageState extends State<RechargePage> {
  late final WalletController controller;
  late final TextEditingController _amountController;
  int _selectedAmount = 0;

  @override
  void initState() {
    super.initState();
    controller = Get.find<WalletController>();
    _amountController = TextEditingController();
    if (controller.rechargeOptions.isNotEmpty) {
      _syncDefaultAmount();
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('recharge_wallet'.tr)),
      body: Obx(() {
        final options = controller.rechargeOptions
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();

        if (_selectedAmount <= 0 && options.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            _syncDefaultAmount();
          });
        }

        if (controller.isLoading.value && options.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('select_amount'.tr, style: AppTextStyles.h4),
                SizedBox(height: 20.h),
                if (options.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 1.8,
                    ),
                    itemCount: options.length,
                    itemBuilder: (context, index) {
                      final option = options[index];
                      final amount = _readAmount(option);
                      final bonus = _readBonus(option);
                      final label = option['label']?.toString() ?? '';

                      return GestureDetector(
                        onTap: () => _selectAmount(amount),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _selectedAmount == amount
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: _selectedAmount == amount
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                          ),
                          padding: EdgeInsets.all(12.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (label.trim().isNotEmpty)
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8.w,
                                    vertical: 4.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _selectedAmount == amount
                                        ? Colors.white.withValues(alpha: 0.18)
                                        : AppColors.secondaryLight.withValues(
                                            alpha: 0.3,
                                          ),
                                    borderRadius: BorderRadius.circular(999.r),
                                  ),
                                  child: Text(
                                    label,
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: _selectedAmount == amount
                                          ? Colors.white
                                          : AppColors.primaryDark,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              SizedBox(
                                height: label.trim().isNotEmpty ? 8.h : 0,
                              ),
                              Text(
                                '₹$amount',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  color: _selectedAmount == amount
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              if (bonus > 0) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  '+₹$bonus bonus',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: _selectedAmount == amount
                                        ? Colors.white
                                        : AppColors.success,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'No recharge options found.',
                      style: AppTextStyles.bodyMedium,
                    ),
                  ),
                SizedBox(height: 24.h),
                Text(
                  'or_enter_custom_amount'.tr,
                  style: AppTextStyles.bodyMedium,
                ),
                SizedBox(height: 12.h),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'enter_amount'.tr,
                    prefixText: '₹ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _selectedAmount = int.tryParse(value) ?? 0;
                    });
                  },
                ),
                SizedBox(height: 32.h),
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'recharge_amount'.tr,
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '₹$_selectedAmount',
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('gst'.tr, style: AppTextStyles.bodyMedium),
                          Text(
                            '₹${(_selectedAmount * (controller.gstPercent.value / 100)).toStringAsFixed(2)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      Divider(height: 24.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'total_amount'.tr,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '₹${(_selectedAmount * (1 + controller.gstPercent.value / 100)).toStringAsFixed(2)}',
                            style: AppTextStyles.h4.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),
                CustomButton(
                  text: 'proceed_to_pay'.tr,
                  isLoading: controller.isRecharging.value,
                  onPressed: () {
                    if (_selectedAmount <= 0) return;
                    final total = _selectedAmount * (1 + controller.gstPercent.value / 100);
                    controller.rechargeWallet(
                      amount: _selectedAmount.toDouble(),
                      totalAmount: total,
                    );
                  },
                  gradient: AppColors.primaryGradient,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _syncDefaultAmount() {
    final options = controller.rechargeOptions
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (options.isEmpty) return;
    final defaultAmount = _readAmount(options.first);
    _selectedAmount = defaultAmount;
    _amountController.text = defaultAmount.toString();
    setState(() {});
  }

  void _selectAmount(int amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toString();
    });
  }

  int _readAmount(Map<String, dynamic> option) {
    final raw = option['amount'];
    if (raw is int) return raw;
    if (raw is double) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  int _readBonus(Map<String, dynamic> option) {
    // If 'bonus' exists directly, use it
    final rawBonus = option['bonus'];
    if (rawBonus != null) {
      if (rawBonus is int) return rawBonus;
      if (rawBonus is double) return rawBonus.toInt();
      return int.tryParse(rawBonus.toString()) ?? 0;
    }

    // Otherwise calculate from cashback_percent
    final rawCashback = option['cashback_percent'];
    final amount = _readAmount(option);
    if (rawCashback != null && amount > 0) {
      double percent = 0;
      if (rawCashback is int) {
        percent = rawCashback.toDouble();
      } else if (rawCashback is double) {
        percent = rawCashback;
      } else {
        percent = double.tryParse(rawCashback.toString()) ?? 0;
      }
      return (amount * percent / 100).toInt();
    }

    return 0;
  }
}
