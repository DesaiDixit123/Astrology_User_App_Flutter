import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/chat_history_detail_controller.dart';

class ChatHistoryDetailPage extends GetView<ChatHistoryDetailController> {
  const ChatHistoryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Obx(() => Row(
          children: [
            CircleAvatar(
              radius: 18.r,
              backgroundColor: Colors.white,
              backgroundImage: controller.partner['profile_pic'] != null && controller.partner['profile_pic'].isNotEmpty
                  ? NetworkImage(controller.partner['profile_pic'])
                  : null,
              child: (controller.partner['profile_pic'] == null || controller.partner['profile_pic'].isEmpty)
                  ? const Icon(Icons.person, color: Colors.grey, size: 18)
                  : null,
            ),
            SizedBox(width: 10.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.partner['name'] ?? 'Astrologer',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'Chat History',
                  style: AppTextStyles.caption.copyWith(
                    color: Colors.white70,
                    fontSize: 11.sp,
                  ),
                ),
              ],
            ),
          ],
        )),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.messages.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_bubble_outline, size: 48.sp, color: Colors.grey.shade300),
                SizedBox(height: 12.h),
                Text('No messages found for this session.', style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: controller.messages.length,
          itemBuilder: (ctx, i) => _buildBubble(controller.messages[i]),
        );
      }),
    );
  }

  Widget _buildBubble(Map msg) {
    final isMe = msg['sender_type'] == 'customer';
    final type = msg['message_type'] ?? 'text';
    final content = msg['text'] as String? ?? '';
    final imageUrl = msg['image'] as String? ?? '';
    final time = _formatTime(msg['createdAt']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: type == 'image' ? 4.w : 14.w, vertical: type == 'image' ? 4.h : 10.h),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: isMe ? Radius.circular(16.r) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  placeholder: (context, url) => Container(
                    height: 150.h,
                    width: 200.w,
                    color: Colors.grey.shade200,
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              )
            else
              Text(
                content,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isMe ? Colors.white : Colors.black87,
                ),
              ),
            SizedBox(height: 4.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: type == 'image' ? 8.w : 0),
              child: Text(
                time,
                style: AppTextStyles.caption.copyWith(
                  fontSize: 10.sp,
                  color: isMe ? Colors.white60 : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
