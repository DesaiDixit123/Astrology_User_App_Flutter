import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/notification_controller.dart';

class NotificationListPage extends StatefulWidget {
  const NotificationListPage({super.key});

  @override
  State<NotificationListPage> createState() => _NotificationListPageState();
}

class _NotificationListPageState extends State<NotificationListPage> {
  final controller = Get.put(NotificationController());
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        controller.fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mark_chat_read_rounded),
            tooltip: 'Mark all as read',
            onPressed: () => controller.markAllAsRead(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 64.sp,
                  color: AppColors.textSecondary.withValues(alpha: 0.5),
                ),
                SizedBox(height: 16.h),
                Text(
                  'No notifications yet',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.fetchNotifications(refresh: true),
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            itemCount: controller.notifications.length +
                (controller.hasMore.value ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final item = controller.notifications[index];
              return _buildNotificationCard(item);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(Map item) {
    final title = item['title'] ?? 'Notification';
    final body = item['body'] ?? '';
    final type = item['type'] ?? 'general';
    final isRead = item['is_read'] == true;
    final createdAtStr = item['createdAt'];
    String timeAgo = '';

    if (createdAtStr != null) {
      try {
        final date = DateTime.parse(createdAtStr).toLocal();
        timeAgo = DateFormat('dd MMM yyyy, hh:mm a').format(date);
      } catch (_) {}
    }

    IconData icon;
    Color iconColor;
    Color iconBgColor;

    switch (type) {
      case 'chat':
        icon = Icons.chat_bubble_rounded;
        iconColor = const Color(0xFFE65100);
        iconBgColor = const Color(0xFFFFF3E0);
        break;
      case 'call':
      case 'video_call':
        icon = Icons.call_rounded;
        iconColor = const Color(0xFF1B5E20);
        iconBgColor = const Color(0xFFE8F5E9);
        break;
      case 'service':
        icon = Icons.card_giftcard_rounded;
        iconColor = const Color(0xFF0D47A1);
        iconBgColor = const Color(0xFFE3F2FD);
        break;
      case 'live':
        icon = Icons.videocam_rounded;
        iconColor = const Color(0xFFB71C1C);
        iconBgColor = const Color(0xFFFFEBEE);
        break;
      default:
        icon = Icons.notifications_active_rounded;
        iconColor = AppColors.primary;
        iconBgColor = AppColors.primary.withValues(alpha: 0.1);
        break;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : const Color(0xFFFFFDF9),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isRead
              ? Colors.grey.withValues(alpha: 0.1)
              : AppColors.primary.withValues(alpha: 0.2),
          width: 1.w,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight:
                              isRead ? FontWeight.w500 : FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  body,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  timeAgo,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textHint,
                    fontSize: 10.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
