import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/chat_history_controller.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/api_constants.dart';

class ChatHistoryPage extends GetView<ChatHistoryController> {
  const ChatHistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'chat_history_title'.tr,
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
        if (controller.historySessions.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: () => controller.fetchChatHistory(),
          child: ListView.separated(
            padding: EdgeInsets.only(top: 8.h, bottom: 100.h),
            itemCount: controller.historySessions.length,
            separatorBuilder: (context, index) =>
                Divider(height: 1, indent: 80.w, color: Colors.grey.shade200),
            itemBuilder: (context, index) =>
                _buildChatTile(controller.historySessions[index]),
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
            Icons.history,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'no_chat_history'.tr,
            style: AppTextStyles.h3.copyWith(color: Colors.grey.shade400),
          ),
          SizedBox(height: 8.h),
          Text(
            'chat_history_subtitle'.tr,
            style: AppTextStyles.bodyMedium.copyWith(color: Colors.grey),
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
            Icon(Icons.error_outline, size: 80.sp, color: Colors.grey.shade300),
            SizedBox(height: 16.h),
            Text(
              'unable_load_history'.tr,
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
              onPressed: () => controller.fetchChatHistory(),
              child: Text('retry'.tr),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatTile(Map session) {
    final partner = session['astrologer_id'] ?? {};
    final personalDetails = partner['personal_details'] as Map? ?? {};
    final name = personalDetails['name'] as String? ?? partner['name'] as String? ?? 'Astrologer';
    final rawImage = personalDetails['profile_image'] as String? ?? partner['profile_pic'] as String? ?? '';
    final imageUrl = ApiConstants.resolveImage(rawImage);

    final cleanPartner = {
      'name': name,
      'profile_pic': imageUrl,
    };

    final dateRaw = session['createdAt'] as String?;
    String dateText = 'Recent';
    if (dateRaw != null && dateRaw.contains('T')) {
      dateText = dateRaw.split('T').first;
    }

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      onTap: () {
        Get.toNamed(
          AppRoutes.chatHistoryDetail,
          arguments: {
            'partner': cleanPartner,
            'sessionId': session['_id'],
          },
        );
      },
      leading: CircleAvatar(
        radius: 28.r,
        backgroundColor: Colors.grey.shade200,
        backgroundImage: imageUrl.isNotEmpty
            ? CachedNetworkImageProvider(imageUrl)
            : null,
        child: imageUrl.isEmpty
            ? Icon(Icons.person, color: Colors.grey, size: 30.sp)
            : null,
      ),
      title: Text(
        name,
        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Padding(
        padding: EdgeInsets.only(top: 4.h),
        child: Row(
          children: [
            const Icon(Icons.history, size: 14, color: Colors.grey),
            SizedBox(width: 4.w),
            Text(
              '${'chat_on'.tr} $dateText',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
    );
  }
}
