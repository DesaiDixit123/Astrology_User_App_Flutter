import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/chat_list_controller.dart';
import '../../../../config/routes/app_routes.dart';

class ChatListPage extends GetView<ChatListController> {
  const ChatListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Chats',
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final error = controller.errorMessage.value;
        if (error.isNotEmpty) {
          return _buildErrorState(error);
        }
        if (controller.sessions.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchChatSessions(),
          child: ListView.separated(
            padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
            itemCount: controller.sessions.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, indent: 80.w, color: Colors.grey.shade200),
            itemBuilder: (context, index) =>
                _buildChatTile(controller.sessions[index]),
          ),
        );
      }),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'No chats yet',
            style: AppTextStyles.h3.copyWith(color: Colors.grey.shade400),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your consultation history will appear here',
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          OutlinedButton.icon(
            onPressed: () => controller.fetchChatSessions(),
            icon: Icon(Icons.refresh, size: 18.sp),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80.sp,
              color: Colors.grey.shade300,
            ),
            SizedBox(height: 16.h),
            Text(
              'Unable to load chats',
              style: AppTextStyles.h3.copyWith(color: Colors.grey.shade500),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            OutlinedButton(
              onPressed: () => controller.fetchChatSessions(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(Map session) {
    final partner = session['astrologer_id'] ?? {};
    final status = session['status'] ?? 'Unknown';
    final isCompleted = status == 'completed';

    return Opacity(
      opacity: isCompleted ? 0.6 : 1.0,
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        onTap: isCompleted
            ? null
            : () {
                Get.toNamed(
                  AppRoutes.chat,
                  arguments: {
                    'partner': partner,
                    'sessionId': session['_id'],
                    'readonly': isCompleted,
                  },
                );
              },
        leading: CircleAvatar(
          radius: 28.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: partner['profile_pic'] != null && partner['profile_pic'].isNotEmpty
              ? CachedNetworkImageProvider(partner['profile_pic'])
              : null,
          child: (partner['profile_pic'] == null || partner['profile_pic'].isEmpty)
              ? Icon(Icons.person, color: Colors.grey, size: 30.sp)
              : null,
        ),
        title: Text(
          partner['name'] ?? 'Astrologer',
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 4.h),
          child: Text(
            isCompleted ? 'Chat Ended' : 'Active Chat',
            style: AppTextStyles.bodySmall.copyWith(
              color: isCompleted ? Colors.grey : AppColors.success,
              fontWeight: isCompleted ? FontWeight.normal : FontWeight.w500,
            ),
          ),
        ),
        trailing: isCompleted
            ? null
            : Container(
                width: 10.w,
                height: 10.w,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
              ),
      ),
    );
  }
}
