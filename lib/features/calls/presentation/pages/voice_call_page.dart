import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/call_controller.dart';

class VoiceCallPage extends GetView<CallController> {
  const VoiceCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background - Blurred Image
          Obx(
            () => Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: CachedNetworkImageProvider(
                    controller.partner['profile_pic'] ??
                        'https://via.placeholder.com/150',
                  ),
                  fit: BoxFit.cover,
                ),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(color: Colors.black.withOpacity(0.6)),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),

                // Partner Avatar
                Obx(
                  () => CircleAvatar(
                    radius: 80,
                    backgroundImage: CachedNetworkImageProvider(
                      controller.partner['profile_pic'] ??
                          'https://via.placeholder.com/150',
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Partner Name
                Obx(
                  () => Text(
                    controller.partner['name'] ?? 'Astrologer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Call Status / Timer
                Obx(() {
                  if (controller.callStatus.value == 'connected') {
                    final duration = controller.callDuration.value;
                    final minutes = (duration ~/ 60).toString().padLeft(2, '0');
                    final seconds = (duration % 60).toString().padLeft(2, '0');
                    String timer = '$minutes:$seconds';
                    if (controller.maxMinutes.value > 0) {
                      timer += ' / ${controller.maxMinutes.value}:00';
                    }
                    return Text(
                      timer,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    );
                  }
                  return Text(
                    controller.callStatus.value.capitalizeFirst!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                }),

                const Spacer(),

                // Wallet Balance Info
                // Obx(() => Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   decoration: BoxDecoration(
                //     color: Colors.white10,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'Balance: ₹${controller.walletBalance.value.toStringAsFixed(2)}',
                //     style: const TextStyle(color: Colors.white),
                //   ),
                // )),
                const SizedBox(height: 40),

                // Controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildControlButton(
                        icon: Icons.volume_up,
                        isActive: controller.isSpeakerOn,
                        onPressed: controller.toggleSpeaker,
                        label: 'Speaker',
                      ),
                      _buildControlButton(
                        icon: Icons.mic_off,
                        isActive: controller.isMuted,
                        onPressed: controller.toggleMute,
                        label: 'Mute',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // End Call Button
                GestureDetector(
                  onTap: controller.endCall,
                  child: Container(
                    height: 70,
                    width: 70,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.call_end,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required RxBool isActive,
    required VoidCallback onPressed,
    required String label,
  }) {
    return Column(
      children: [
        Obx(
          () => GestureDetector(
            onTap: onPressed,
            child: Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                color: isActive.value ? Colors.white : Colors.white10,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isActive.value ? Colors.black : Colors.white,
                size: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }
}
