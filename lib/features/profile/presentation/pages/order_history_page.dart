import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/profile_controller.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final controller = Get.find<ProfileController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.refreshOrders();
    });
  }

  String _orderId(Map<String, dynamic> order) {
    final id = order['order_id']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return order['_id']?.toString() ?? '-';
  }

  String _astrologerName(Map<String, dynamic> order) {
    final astrologer = order['astrologer_id'];
    if (astrologer is Map) {
      final personal = astrologer['personal_details'];
      if (personal is Map && personal['name'] != null) {
        return personal['name'].toString();
      }
      if (astrologer['name'] != null) {
        return astrologer['name'].toString();
      }
    }
    return 'Astrologer';
  }

  String? _astrologerImage(Map<String, dynamic> order) {
    final astrologer = order['astrologer_id'];
    if (astrologer is Map) {
      final image =
          astrologer['profile_pic'] ?? astrologer['profile_image'] ?? '';
      if (image != null && image.toString().isNotEmpty) {
        return ApiConstants.resolveImage(image.toString());
      }
    }
    return null;
  }

  String _typeLabel(Map<String, dynamic> order) {
    final type = order['type']?.toString().toLowerCase() ?? 'call';
    if (type == 'video_call') return 'Video Call';
    return 'Call';
  }

  String _durationText(Map<String, dynamic> order) {
    final seconds = order['duration'];
    final totalSeconds = seconds is num ? seconds.toInt() : 0;
    if (totalSeconds <= 0) return '0 min';
    final minutes = (totalSeconds / 60).ceil();
    return '$minutes min';
  }

  String _amountText(Map<String, dynamic> order) {
    final amount = order['amount_charged'];
    final value = amount is num ? amount.toDouble() : 0.0;
    if (value == value.roundToDouble()) {
      return '₹${value.toInt()}';
    }
    return '₹${value.toStringAsFixed(2)}';
  }

  String _dateText(Map<String, dynamic> order) {
    final raw = order['started_at'] ?? order['createdAt'] ?? order['ended_at'];
    if (raw == null) return '-';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (_) {
      return raw.toString();
    }
  }

  bool _isCompleted(Map<String, dynamic> order) {
    return (order['status']?.toString().toLowerCase() ?? '') == 'completed';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('order_history_title'.tr)),
      body: Obx(() {
        if (controller.isLoading.value && controller.orders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.orders.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No order history yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.astrologerList),
                    icon: const Icon(Icons.search),
                    label: const Text('Find an Astrologer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshOrders,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.orders.length,
            itemBuilder: (context, index) {
              final order = Map<String, dynamic>.from(controller.orders[index]);
              return _buildOrderCard(order);
            },
          ),
        );
      }),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final isCompleted = _isCompleted(order);
    final statusKey = isCompleted ? 'completed' : 'cancelled';
    final imageUrl = _astrologerImage(order);

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order #${_orderId(order)}',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
             
            ],
          ),
           Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  statusKey.tr,
                  style: AppTextStyles.caption.copyWith(
                    color: isCompleted ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          SizedBox(height: 12.h),
          Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                child: imageUrl == null
                    ? Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24.sp,
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _astrologerName(order),
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${_typeLabel(order)} • ${_durationText(order)}',
                      style: AppTextStyles.caption,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(color: AppColors.border),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('date_label'.tr, style: AppTextStyles.caption),
                  SizedBox(height: 4.h),
                  Text(
                    _dateText(order),
                    style: AppTextStyles.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('amount_label'.tr, style: AppTextStyles.caption),
                  SizedBox(height: 4.h),
                  Text(
                    _amountText(order),
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (isCompleted) ...[
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final astrologer = order['astrologer_id'];
                      if (astrologer is Map) {
                        Get.toNamed(
                          AppRoutes.astrologerDetail,
                          arguments: Map<String, dynamic>.from(astrologer),
                        );
                      }
                    },
                    icon: Icon(Icons.refresh, size: 18.sp),
                    label: Text('rebook'.tr),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
                // SizedBox(width: 8.w),
                // Expanded(
                //   child: ElevatedButton.icon(
                //     onPressed: () {},
                //     icon: Icon(Icons.star_border, size: 18.sp),
                //     label: Text('rate'.tr),
                //     style: ElevatedButton.styleFrom(
                //       backgroundColor: AppColors.primary,
                //     ),
                //   ),
                // ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
