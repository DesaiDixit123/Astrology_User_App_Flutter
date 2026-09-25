import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/gujarati_script_utils.dart';
import '../../../../core/utils/astrologer_utils.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/call_history_controller.dart';

class CallListPage extends GetView<CallHistoryController> {
  const CallListPage({super.key});

  String _astrologerName(Map<String, dynamic> session) {
    return AstrologerUtils.getLocalizedAstrologerName(session);
  }

  String? _astrologerImage(Map<String, dynamic> session) {
    final astrologer = session['astrologer_id'];
    if (astrologer is Map) {
      final image =
          astrologer['profile_pic'] ?? astrologer['profile_image'] ?? '';
      if (image != null && image.toString().isNotEmpty) {
        return ApiConstants.resolveImage(image.toString());
      }
    }
    return null;
  }

  String _status(Map<String, dynamic> session) {
    return (session['status']?.toString() ?? 'pending')
        .replaceAll('_', ' ')
        .capitalizeFirst!;
  }

  bool _isMissed(Map<String, dynamic> session) {
    const missedStatuses = {'missed', 'rejected', 'failed', 'cancelled'};
    final status = session['status']?.toString().toLowerCase() ?? '';
    return missedStatuses.contains(status);
  }

  String _durationText(Map<String, dynamic> session) {
    final seconds = session['duration'];
    final totalSeconds = seconds is num ? seconds.toInt() : 0;
    if (totalSeconds <= 0) return '0 mins';
    final minutes = (totalSeconds / 60).ceil();
    return '$minutes mins';
  }

  String _costText(Map<String, dynamic> session) {
    final charged = session['amount_charged'];
    final amount = charged is num ? charged.toDouble() : 0.0;
    if (amount == amount.roundToDouble()) {
      return '₹${amount.toInt()}';
    }
    return '₹${amount.toStringAsFixed(2)}';
  }

  String _timeText(Map<String, dynamic> session) {
    final raw = session['started_at'] ?? session['createdAt'] ?? session['ended_at'];
    if (raw == null) return '';

    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final date = DateTime(dt.year, dt.month, dt.day);
      final daysDiff = today.difference(date).inDays;

      final time = DateFormat('hh:mm a').format(dt);
      if (daysDiff == 0) return 'Today, $time';
      if (daysDiff == 1) return 'Yesterday, $time';
      return '${DateFormat('dd MMM').format(dt)}, $time';
    } catch (_) {
      return raw.toString();
    }
  }

  Color _statusColor(Map<String, dynamic> session) {
    if (_isMissed(session)) return Colors.red;
    final status = session['status']?.toString().toLowerCase() ?? '';
    if (status == 'completed') return Colors.green;
    return Colors.orange;
  }

  IconData _callIcon(Map<String, dynamic> session) {
    if (_isMissed(session)) return Icons.call_missed;
    final type = session['type']?.toString().toLowerCase() ?? 'call';
    return type == 'video_call' ? Icons.videocam : Icons.call_made;
  }

  Color _callIconColor(Map<String, dynamic> session) {
    if (_isMissed(session)) return Colors.red;
    final type = session['type']?.toString().toLowerCase() ?? 'call';
    return type == 'video_call' ? AppColors.primary : Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Call History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.sessions.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.errorMessage.value.isNotEmpty &&
            controller.sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 56.sp,
                    color: Colors.grey.shade400,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    controller.errorMessage.value,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: controller.fetchCallHistory,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        if (controller.sessions.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.call_outlined,
                    size: 64.sp,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No call history yet',
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
          onRefresh: controller.fetchCallHistory,
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.sessions.length,
            itemBuilder: (context, index) {
              final session = controller.sessions[index];
              return _buildCallCard(session);
            },
          ),
        );
      }),
    );
  }

  Widget _buildCallCard(Map<String, dynamic> session) {
    final imageUrl = _astrologerImage(session);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Icon(
                    _callIcon(session),
                    color: _callIconColor(session),
                  )
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _astrologerName(session),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  '${_timeText(session)} • ${_durationText(session)}',
                  style: AppTextStyles.caption,
                ),
                SizedBox(height: 6.h),
                Row(
                  children: [
                    Icon(
                      _callIcon(session),
                      size: 14.sp,
                      color: _callIconColor(session),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      (session['type']?.toString() ?? 'call')
                          .replaceAll('_', ' ')
                          .capitalizeFirst!,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _costText(session),
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                _status(session),
                style: AppTextStyles.caption.copyWith(
                  color: _statusColor(session),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
