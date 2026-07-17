import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/call_controller.dart';

class VideoCallPage extends GetView<CallController> {
  const VideoCallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Remote Video (Full Screen)
          Obx(() {
            if (controller.remoteUid.value != 0) {
              return AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: controller.engine,
                  canvas: VideoCanvas(uid: controller.remoteUid.value),
                  connection: RtcConnection(
                    channelId: controller.currentSession['channel'],
                  ),
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Colors.white),
                  const SizedBox(height: 20),
                  Text(
                    'Waiting for ${controller.partner['name'] ?? 'Astrologer'}...',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            );
          }),

          // Local Video (Small Overlay)
          Positioned(
            top: 50,
            right: 20,
            child: Obx(
              () => controller.isVideoOn.value
                  ? Container(
                      width: 120,
                      height: 180,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white24, width: 2),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AgoraVideoView(
                        controller: VideoViewController(
                          rtcEngine: controller.engine,
                          canvas: const VideoCanvas(uid: 0),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
          ),

          // Header Info
          Positioned(
            top: 50,
            left: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Obx(
                  () => Text(
                    controller.partner['name'] ?? 'Astrologer',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  ),
                ),
                Obx(() {
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
                      shadows: [Shadow(blurRadius: 10, color: Colors.black)],
                    ),
                  );
                }),
              ],
            ),
          ),

          // Controls (Bottom)
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Balance indicator
                // Obx(() => Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: Colors.black45,
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'Wallet: ₹${controller.walletBalance.value.toStringAsFixed(2)}',
                //     style: const TextStyle(color: Colors.white, fontSize: 12),
                //   ),
                // )),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildCircleButton(
                      icon: Icons.switch_camera,
                      onPressed: controller.switchCamera,
                    ),
                    Obx(
                      () => _buildCircleButton(
                        icon: controller.isVideoOn.value
                            ? Icons.videocam
                            : Icons.videocam_off,
                        onPressed: controller.toggleVideo,
                        color: controller.isVideoOn.value
                            ? Colors.white24
                            : Colors.redAccent,
                      ),
                    ),
                    Obx(
                      () => _buildCircleButton(
                        icon: controller.isMuted.value
                            ? Icons.mic_off
                            : Icons.mic,
                        onPressed: controller.toggleMute,
                        color: controller.isMuted.value
                            ? Colors.redAccent
                            : Colors.white24,
                      ),
                    ),
                    _buildCircleButton(
                      icon: Icons.call_end,
                      onPressed: controller.endCall,
                      color: Colors.red,
                      iconSize: 32,
                      size: 65,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onPressed,
    Color color = Colors.white24,
    double size = 50,
    double iconSize = 24,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: size,
        width: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: iconSize),
      ),
    );
  }
}
