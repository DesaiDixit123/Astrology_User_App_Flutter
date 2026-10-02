import 'package:astrology_user/core/utils/gujarati_script_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/astrologer_utils.dart';
import '../controllers/chat_controller.dart';

class ChatPage extends GetView<ChatController> {
  const ChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: controller.isEnded.value,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (controller.isEnded.value) {
          Navigator.pop(context);
          return;
        }

        controller.confirmAndEndChat();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: Obx(() {
            final bool isAi = controller.partner['is_ai'] == true ||
                controller.currentSession['is_ai'] == true ||
                (controller.partner['_id']?.toString().startsWith('6aa00000000000000000000') ?? false);
            final astroPic = AstrologerUtils.getAstrologerImage(controller.partner);
            return Row(
              children: [
                if (isAi)
                  _buildAiAvatar(controller.partner, 36.r)
                else
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: Colors.white,
                    backgroundImage: astroPic.isNotEmpty
                        ? CachedNetworkImageProvider(ApiConstants.resolveImage(astroPic))
                        : null,
                    child: astroPic.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey, size: 18)
                        : null,
                  ),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    GujaratiScriptUtils.toGujaratiName(controller.partner['name']?.toString() ?? 'astrologer'.tr),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!controller.isReadOnly.value)
                  Text(
                    _getTimerText(controller.chatDuration.value, controller.partner['chat_price'] ?? 10),
                    style: AppTextStyles.caption.copyWith(
                      color: Colors.white70,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ],
          );
        }),
          actions: [
            if (!controller.isReadOnly.value)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => controller.confirmAndEndChat(),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (controller.isQueued.value) {
            return _buildQueueWaitingView(context);
          }
          return Column(
            children: [
              if (!controller.isReadOnly.value) _buildStatusBanner(),
              Expanded(child: _buildMessageList()),
              if (!controller.isReadOnly.value) _buildInputBar(),
            ],
          );
        }),
      ),
    ));
  }

  Widget _buildQueueWaitingView(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.8, end: 1.1),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeInOut,
                builder: (_, scale, child) => Transform.scale(scale: scale, child: child),
                child: Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.chat_bubble_outline_rounded, size: 44.sp, color: AppColors.primary),
                ),
              ),
              SizedBox(height: 28.h),
              Text(
                'waiting_queue'.tr,
                style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              SizedBox(height: 10.h),
              Text(
                'queue_status'.trArgs([controller.queuePosition.value.toString()]),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall.copyWith(color: Colors.grey.shade600),
              ),
              SizedBox(height: 8.h),
              const LinearProgressIndicator(),
              SizedBox(height: 32.h),
              OutlinedButton.icon(
                icon: const Icon(Icons.exit_to_app, color: Colors.red),
                label: Text('leave_queue'.tr, style: const TextStyle(color: Colors.red)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                ),
                onPressed: () => controller.cancelQueue(),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildStatusBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      color: Colors.amber.shade50,
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 14.sp, color: Colors.amber.shade800),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'chat_status_banner'.tr,
              style: AppTextStyles.caption.copyWith(
                color: Colors.amber.shade800,
                fontSize: 11.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return Obx(() {
      if (controller.messages.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.chat_bubble_outline, size: 48.sp, color: Colors.grey.shade300),
              SizedBox(height: 12.h),
              Text('no_messages_yet'.tr, style: AppTextStyles.bodySmall.copyWith(color: Colors.grey)),
            ],
          ),
        );
      }

      return ListView.builder(
        controller: controller.scrollController,
        padding: EdgeInsets.all(16.w),
        itemCount: controller.messages.length + (controller.isOtherTyping.value ? 1 : 0),
        itemBuilder: (ctx, i) {
          if (i == controller.messages.length && controller.isOtherTyping.value) {
            return _buildTypingIndicator();
          }
          return _buildBubble(controller.messages[i]);
        },
      );
    });
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h, top: 4.h),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: const Radius.circular(4),
            bottomRight: Radius.circular(16.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'typing'.tr,
          style: AppTextStyles.bodySmall.copyWith(
            color: Colors.black54,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(Map msg) {
    final isMe = msg['sender_type'] == 'customer';
    final type = msg['message_type'] ?? 'text';
    final content = msg['text'] as String? ?? '';
    final rawImage = msg['image'] as String? ?? '';
    final imageUrl = ApiConstants.resolveImage(rawImage);
    final isImage = (type == 'image' || rawImage.isNotEmpty) && imageUrl.isNotEmpty && imageUrl.startsWith('http');
    final time = _formatTime(msg['createdAt']);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        constraints: BoxConstraints(maxWidth: 0.75.sw),
        padding: EdgeInsets.symmetric(horizontal: isImage ? 4.w : 14.w, vertical: isImage ? 4.h : 10.h),
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
            if (isImage)
              GestureDetector(
                onTap: () {
                  Get.dialog(
                    Dialog(
                      backgroundColor: Colors.black87,
                      insetPadding: EdgeInsets.all(12.w),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          InteractiveViewer(
                            panEnabled: true,
                            minScale: 0.8,
                            maxScale: 4.0,
                            child: Center(
                              child: CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(color: Colors.white),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(Icons.broken_image, color: Colors.white, size: 48),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: IconButton(
                              icon: const Icon(Icons.close, color: Colors.white, size: 28),
                              onPressed: () => Get.back(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 200.w,
                    placeholder: (context, url) => Container(
                      height: 150.h,
                      width: 200.w,
                      color: Colors.grey.shade200,
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 150.h,
                      width: 200.w,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                    fit: BoxFit.cover,
                  ),
                ),
              )
            else if (type == 'image')
              ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  height: 150.h,
                  width: 200.w,
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image, color: Colors.grey),
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

  Widget _buildInputBar() {
    final TextEditingController msgController = TextEditingController();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.add_photo_alternate_outlined, color: AppColors.primary),
              onPressed: () => _showAttachmentOptions(Get.context!),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(24.r),
                ),
                child: TextField(
                  controller: msgController,
                  decoration: InputDecoration(
                    hintText: 'type_message_hint'.tr,
                    border: InputBorder.none,
                    hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: controller.onMessageChanged,
                  onSubmitted: (_) {
                    if (msgController.text.trim().isNotEmpty) {
                      controller.sendMessage(msgController.text.trim());
                      msgController.clear();
                    }
                  },
                ),
              ),
            ),
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: () {
                if (msgController.text.trim().isNotEmpty) {
                  controller.sendMessage(msgController.text.trim());
                  msgController.clear();
                }
              },
              child: Obx(() => Container(
                width: 44.w,
                height: 44.h,
                decoration: BoxDecoration(
                  color: (controller.isSending.value || controller.isUploading.value) ? Colors.grey : AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: (controller.isSending.value || controller.isUploading.value)
                    ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send, color: Colors.white, size: 20),
              )),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('send_image'.tr, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _attachmentItem(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    controller.pickAndSendImage(ImageSource.camera);
                  },
                ),
                _attachmentItem(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    controller.pickAndSendImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _attachmentItem({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 28.sp),
          ),
          SizedBox(height: 8.h),
          Text(label, style: AppTextStyles.bodySmall),
        ],
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

  String _getTimerText(int seconds, num price) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    String timer = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    
    final isAi = controller.partner['is_ai'] == true ||
        controller.currentSession['is_ai'] == true ||
        (controller.partner['_id']?.toString().startsWith('6aa00000000000000000000') ?? false);
    if (isAi) {
      return '$timer • FREE AI CHAT';
    }

    if (controller.maxMinutes.value > 0) {
      return '$timer / ${controller.maxMinutes.value}:00 min';
    }
    
    int chargeableMins = (seconds / 60).ceil();
    return '$timer (₹${chargeableMins * price})';
  }

  Widget _buildAiAvatar(Map astro, double size) {
    final name = (astro['name'] ?? '').toString();

    List<Color> gradientColors;
    IconData iconData;
    IconData faceIcon;

    if (name.contains('Aarav')) {
      gradientColors = const [Color(0xFFFF9933), Color(0xFFFF5722)];
      iconData = Icons.auto_awesome;
      faceIcon = Icons.face;
    } else if (name.contains('Rohan')) {
      gradientColors = const [Color(0xFF1E3C72), Color(0xFF2A5298)];
      iconData = Icons.insights_rounded;
      faceIcon = Icons.face;
    } else if (name.contains('Gautam')) {
      gradientColors = const [Color(0xFF00796B), Color(0xFF004D40)];
      iconData = Icons.diamond_outlined;
      faceIcon = Icons.face;
    } else if (name.contains('Ragini')) {
      gradientColors = const [Color(0xFFE91E63), Color(0xFFFF6090)];
      iconData = Icons.spa_rounded;
      faceIcon = Icons.face_3;
    } else if (name.contains('Shloka')) {
      gradientColors = const [Color(0xFF7B1FA2), Color(0xFF4A148C)];
      iconData = Icons.style_rounded;
      faceIcon = Icons.face_3;
    } else {
      gradientColors = const [Color(0xFFD81B60), Color(0xFF880E4F)];
      iconData = Icons.visibility_rounded;
      faceIcon = Icons.face_3;
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            faceIcon,
            color: Colors.white,
            size: size * 0.58,
          ),
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: Icon(
                iconData,
                color: const Color(0xFFFFD54F),
                size: size * 0.22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
