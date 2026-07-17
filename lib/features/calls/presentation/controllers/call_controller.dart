import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class CallController extends GetxController {
  final RxMap currentSession = {}.obs;
  final RxMap partner = {}.obs;
  final RxBool isLoading = false.obs;
  final RxString callStatus = 'idle'
      .obs; // 'idle', 'calling', 'ringing', 'queued', 'connected', 'ended'
  final RxInt callDuration = 0.obs;
  final RxInt maxMinutes = 0.obs;
  final RxBool isMuted = false.obs;
  final RxBool isVideoOn = true.obs;
  final RxBool isSpeakerOn = true.obs;
  final RxInt remoteUid = 0.obs;
  final RxDouble walletBalance = 0.0.obs;

  late RtcEngine engine;
  IO.Socket? _socket;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final _api = ApiService.instance;
  Timer? _durationTimer;
  String _userId = '';

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null) {
      partner.value = args['partner'] ?? {};
    }
    _loadUserAndInit();
  }

  Future<void> _loadUserAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(AppConstants.keyUserId) ?? '';

    if (Get.isRegistered<WalletController>()) {
      walletBalance.value = Get.find<WalletController>().walletBalance.value;
    }

    _initSocket();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    _durationTimer?.cancel();
    _disposeAgora();
    _socket?.disconnect();
    super.onClose();
  }

  void _initSocket() {
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket?.onConnect((_) => print('Call: Connected to Socket.io'));

    _socket?.on('partner_joined', (data) {
      print('Partner joined the call');
      _audioPlayer.stop();
      if (Get.isDialogOpen == true) Get.back();
      callStatus.value = 'connected';
      callDuration.value = 0;
      _startTimer();
      SnackbarUtil.success('Astrologer connected!');
    });

    _socket?.on('call_ended', (data) {
      _handleCallEnded(data);
    });

    _socket?.on('balance_update', (data) {
      if (data is Map && data['newBalance'] != null) {
        walletBalance.value = (data['newBalance'] as num).toDouble();
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().walletBalance.value =
              walletBalance.value;
        }
      }
    });

    _socket?.on('waiting_time', (data) {
      if (data is Map && data['waitingTime'] != null) {
        _showBusyDialog(data['waitingTime']);
      }
    });
  }

  void _joinSocketRoom(String sessionId, String type) {
    _socket?.emit('join_call', {
      'session_id': sessionId,
      'customer_id': _userId,
      'astrologer_id': partner['_id'],
      'price_per_min': currentSession['price_per_minute'] ?? 10,
      'type': type,
      'participant_type': 'customer',
    });
  }

  /// Initiate call or video call
  Future<void> initiateCall(String astrologerId, {String type = 'call'}) async {
    isLoading.value = true;
    callStatus.value = 'calling';

    // Request Permissions
    final micStatus = await Permission.microphone.request();
    if (type == 'video_call') {
      await Permission.camera.request();
    }

    if (micStatus.isDenied) {
      isLoading.value = false;
      callStatus.value = 'idle';
      SnackbarUtil.error('Microphone permission is required for calls.');
      return;
    }

    final res = await _api.post(
      ApiConstants.initiateCall,
      data: {'astrologer_id': astrologerId, 'type': type},
    );
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>;
      currentSession.value = data;
      maxMinutes.value = data['max_minutes'] ?? 0;

      if (data['status'] == 'queued') {
        callStatus.value = 'queued';
        _showBusyDialog(data['waiting_time'] ?? 5);
      } else {
        await _initAgora(
          appId: data['agora_app_id'],
          channel: data['channel'],
          token: data['agora_token'],
          isVideo: type == 'video_call',
        );
        _joinSocketRoom(data['session_id'], type);

        // Play outgoing ringtone
        _audioPlayer.setReleaseMode(ReleaseMode.loop);
        _audioPlayer.play(AssetSource('outgoing_call.mp3'));

        // Navigate to call page
        if (type == 'video_call') {
          Get.toNamed('/video-call');
        } else {
          Get.toNamed('/voice-call');
        }
      }
    } else {
      callStatus.value = 'idle';
      final errorMsg = ApiService.getMessage(res);
      if (errorMsg.toLowerCase().contains('insufficient wallet balance') ||
          errorMsg.toLowerCase().contains('wallet balance')) {
        _showRechargeDialog(errorMsg);
      } else {
        SnackbarUtil.error(errorMsg);
      }
    }
  }

  Future<void> _initAgora({
    required String appId,
    required String channel,
    required String token,
    required bool isVideo,
  }) async {
    engine = createAgoraRtcEngine();
    await engine.initialize(RtcEngineContext(appId: appId));

    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          print('Joined Agora channel: ${connection.channelId}');
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          print('Remote user joined: $remoteUid');
          this.remoteUid.value = remoteUid;
        },
        onUserOffline:
            (
              RtcConnection connection,
              int remoteUid,
              UserOfflineReasonType reason,
            ) {
              print('Remote user offline: $remoteUid');
              this.remoteUid.value = 0;
              endCall();
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          print('Left Agora channel');
        },
      ),
    );

    if (isVideo) {
      await engine.enableVideo();
      await engine.startPreview();
    } else {
      await engine.enableAudio();
    }

    await engine.setClientRole(role: ClientRoleType.clientRoleBroadcaster);
    await engine.joinChannel(
      token: token,
      channelId: channel,
      uid: 0,
      options: const ChannelMediaOptions(
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        publishCameraTrack: true,
        publishMicrophoneTrack: true,
      ),
    );
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
    });
  }

  Future<void> toggleMute() async {
    isMuted.value = !isMuted.value;
    await engine.muteLocalAudioStream(isMuted.value);
  }

  Future<void> toggleVideo() async {
    isVideoOn.value = !isVideoOn.value;
    await engine.muteLocalVideoStream(!isVideoOn.value);
  }

  Future<void> switchCamera() async {
    await engine.switchCamera();
  }

  Future<void> toggleSpeaker() async {
    isSpeakerOn.value = !isSpeakerOn.value;
    await engine.setEnableSpeakerphone(isSpeakerOn.value);
  }

  Future<void> endCall() async {
    final sessionId = currentSession['session_id'] ?? currentSession['_id'];
    final isCallConnected = callStatus.value == 'connected';

    // Use HTTP API to securely terminate
    try {
      await _api.post(
        ApiConstants.endCall,
        data: {'session_id': sessionId, 'duration': callDuration.value},
      );
    } catch (_) {}

    _socket?.emit('end_call', {
      'session_id': sessionId,
      'reason': 'user_ended',
    });
    _cleanupAndExit();
    if (isCallConnected) {
      _showRatingDialog();
    }
  }

  void _handleCallEnded(dynamic data) {
    final isCallConnected = callStatus.value == 'connected';
    _cleanupAndExit();

    final Map summary = data is Map ? data : {};
    final String reason = summary['reason'] ?? 'Call completed';
    final double totalCharge =
        (summary['total_charge'] as num?)?.toDouble() ?? 0.0;

    if (reason == 'insufficient_balance') {
      _showRechargeDialog(
        'Your call was automatically ended due to low balance. Please recharge your wallet.',
      );
    } else {
      SnackbarUtil.success('Call ended. Total charge: ₹$totalCharge');
      if (isCallConnected) {
        _showRatingDialog();
      }
    }
  }

  void _exitCallScreen() {
    if (Get.isDialogOpen == true) Get.back();
    final route = Get.currentRoute;
    if (route.contains('call')) {
      _safePop();
    }
  }

  void _cleanupAndExit() {
    _audioPlayer.stop();
    _durationTimer?.cancel();
    _disposeAgora();

    callStatus.value = 'idle';
    _exitCallScreen();
  }

  void _safePop() {
    try {
      if (Get.context != null) {
        Navigator.of(Get.context!).pop();
      } else {
        Get.back();
      }
    } catch (e) {
      Get.back();
    }
  }

  Future<void> _disposeAgora() async {
    try {
      await engine.leaveChannel();
      await engine.release();
    } catch (e) {
      print('Error disposing Agora: $e');
    }
  }

  void _showBusyDialog(dynamic minutes) {
    if (Get.isDialogOpen == true) return;
    Get.defaultDialog(
      title: 'Astrologer is Busy',
      middleText:
          'The astrologer is currently on another call. Estimated wait: $minutes mins. Wait or exit?',
      barrierDismissible: false,
      textConfirm: 'Wait',
      onConfirm: () => _safePop(),
      textCancel: 'Exit',
      onCancel: () => endCall(),
    );
  }

  void _showRechargeDialog(String message) {
    Get.defaultDialog(
      title: 'Low Balance',
      middleText: message,
      textConfirm: 'Recharge',
      textCancel: 'Cancel',
      onConfirm: () {
        _safePop();
        Get.toNamed(AppRoutes.recharge);
      },
    );
  }

  void _showRatingDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: 'Rate your Experience',
      titleStyle: AppTextStyles.h4.copyWith(fontWeight: FontWeight.bold),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('How was your call with the astrologer?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32.sp,
                    ),
                    onPressed: () => setState(() => selectedRating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: 'Add a comment (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              SizedBox(height: 20.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () {
                        Get.offAllNamed(AppRoutes.dashboard);
                      },
                      child: const Text('Skip'),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      onPressed: () {
                        submitReview(selectedRating, commentController.text.trim());
                        Get.offAllNamed(AppRoutes.dashboard);
                      },
                      child: const Text('Submit'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
      barrierDismissible: false,
    );
  }

  Future<void> submitReview(int rating, String comment) async {
    final res = await _api.post('/customer/review', data: {
      'astrologer_id': partner['_id'],
      'rating': rating,
      'comment': comment,
      'session_id': currentSession['session_id'] ?? currentSession['_id'],
    });

    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Thank you for your feedback!');
    }
  }
}
