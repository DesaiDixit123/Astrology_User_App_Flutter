import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart' as dio;
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import 'chat_list_controller.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../astrologers/presentation/controllers/astrologer_controller.dart';

class ChatController extends GetxController {
  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxBool isEnded = false.obs;
  final RxBool isQueued = false.obs;
  final RxInt queuePosition = 0.obs;
  final RxString queueId = ''.obs;
  final RxInt chatDuration = 0.obs;
  final RxInt maxMinutes = 0.obs;
  final RxMap currentSession = {}.obs;
  final RxMap partner = {}.obs;
  final RxBool isOtherTyping = false.obs;
  final RxBool isBusy = false.obs;
  final RxBool isReadOnly = false.obs;
  final RxBool isUploading = false.obs;

  final ImagePicker _picker = ImagePicker();

  IO.Socket? _socket;
  final _api = ApiService.instance;
  Timer? _durationTimer;
  final ScrollController scrollController = ScrollController();
  Timer? _typingDebounce;
  String _userId = '';
  String _userName = '';
  String _userProfilePic = '';
  bool _hasPartnerJoined = false;
  String? _joinedRoomId;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    final isExisting = args?['_existing_controller'] == true;
    if (!isExisting) {
      partner.value = (args?['partner'] is Map) ? args!['partner'] : args ?? {};
    }
    _loadUserAndInit();
  }

  Future<void> _loadUserAndInit() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(AppConstants.keyUserId) ?? '';
    _userName = prefs.getString(AppConstants.keyUserName) ?? 'User';
    // _userProfilePic = prefs.getString(AppConstants.keyUserProfilePic) ?? '';
    
    final args = Get.arguments as Map?;
    isReadOnly.value = args?['readonly'] == true;

    // If this page was opened by the partner_joined handler (same controller reused),
    // skip re-init to avoid creating a second socket.
    final isExisting = args?['_existing_controller'] == true;
    if (isExisting) return;

    if (!isReadOnly.value) {
      _initSocket();
    }
    
    if (args?['sessionId'] != null) {
      _resumeSession(args!['sessionId']);
    }
  }

  @override
  void onClose() {
    _durationTimer?.cancel();
    _typingDebounce?.cancel();
    scrollController.dispose();
    _socket?.disconnect();
    _refreshStatusDependentData();
    if (Get.isRegistered<ChatListController>()) {
      Get.find<ChatListController>().fetchChatSessions();
    }
    super.onClose();
  }

  void _initSocket() {
    _socket = IO.io(ApiConstants.baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    _socket?.onConnect((_) {
      print('Chat: Connected to Socket.io');
      _joinedRoomId = ''; // Clear joined room id so we can rejoin!
      if (currentSession['_id'] != null) {
        _joinRoom(currentSession['_id']);
      }
    });

    _socket?.on('receive_message', (data) {
      if (data is Map) {
        messages.add(data);
        _scrollToBottom();
      }
    });

    _socket?.on('typing', (data) {
      if (data is Map) {
        isOtherTyping.value = data['is_typing'] == true;
      }
    });

    _socket?.on('balance_update', (data) {
      if (data is Map && data['newBalance'] != null) {
        if (Get.isRegistered<WalletController>()) {
          final walletCtrl = Get.find<WalletController>();
          walletCtrl.walletBalance.value = (data['newBalance'] as num).toDouble();
        }
      }
    });

    _socket?.on('chat_ended', (data) {
      isEnded.value = true;
      _durationTimer?.cancel();
      _showEndedDialog(data is Map ? data : {});
    });

    _socket?.on('waiting_time', (data) {
      if (data is Map && data['waitingTime'] != null) {
        if (!isEnded.value && !isOtherTyping.value) { // Basic guards
          _showBusyDialog(data['waitingTime']);
        }
      }
    });

    _socket?.on('partner_joined', (data) {
      print('Partner joined the chat room');
      if (data is Map && data['session_id'] != null) {
        currentSession.value = {'_id': data['session_id']};
      }
      
      if (Get.isDialogOpen == true) Get.back(); // Close waiting/busy dialog
      
      isQueued.value = false;
      // ✅ FIXED: Only start timer ONCE — do NOT reset chatDuration on every partner_joined
      if (!_hasPartnerJoined) {
        _hasPartnerJoined = true;
        chatDuration.value = 0; // Reset only on FIRST join
        SnackbarUtil.success('Astrologer connected!');
        _startTimer();
      }
      
      // Navigate to chat screen reusing this same controller
      if (Get.currentRoute != AppRoutes.chat) {
        // Put the current controller so chat page reuses it instead of creating new
        Get.put<ChatController>(this, permanent: false);
        Get.toNamed(AppRoutes.chat, arguments: {
          'sessionId': currentSession['_id'],
          'partner': partner.value,
          '_existing_controller': true,
        });
      } else if (messages.isEmpty && currentSession['_id'] != null) {
        _resumeSession(currentSession['_id']);
      }
    });
    // Add listeners for call/video events as needed
    // _socket?.on('call_request', ...);
    // _socket?.on('video_call_request', ...);
  }

  void _joinRoom(String sessionId) {
    // ✅ FIXED: Only emit join_chat once per session to prevent partner_joined re-trigger
    if (_joinedRoomId == sessionId) return;
    _joinedRoomId = sessionId;
    _socket?.emit('join_chat', {
      'session_id': sessionId,
      'customer_id': _customerId,
      'astrologer_id': partner['_id'],
      'price_per_min': partner['pricePerMinute'] ?? partner['chat_price'] ?? 10,
      'participant_type': 'customer',
      'customer': {
        '_id': _customerId,
        'name': _userName,
        'profile_pic': _userProfilePic
      }
    });
  }

  void onMessageChanged(String text) {
    if (currentSession['_id'] == null) return;
    _socket?.emit('typing', {
      'session_id': currentSession['_id'],
      'is_typing': true
    });

    _typingDebounce?.cancel();
    _typingDebounce = Timer(const Duration(seconds: 2), () {
      _socket?.emit('typing', {
        'session_id': currentSession['_id'],
        'is_typing': false
      });
    });
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _customerId => _userId;

  Future<void> initiateChat() async {
    // Reset state for a new session
    messages.clear();
    isEnded.value = false;
    isQueued.value = false;
    isBusy.value = false;
    isOtherTyping.value = false;
    isSending.value = false;
    isUploading.value = false;
    isReadOnly.value = false;
    chatDuration.value = 0;
    maxMinutes.value = 0;
    currentSession.value = {};
    
    isLoading.value = true;
    final res = await _api.post('/customer/chat/initiate', data: {
      'astrologer_id': partner['_id']
    });
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>;

      if (data['status'] == 'queued') {
        isQueued.value = true;
        queuePosition.value = data['queue_position'] ?? 0;
        queueId.value = (data['queue_id'] ?? '').toString();
        currentSession.value = {};
        
        _showWaitingDialog('You are #${queuePosition.value} in queue. Waiting for astrologer to accept...');
        return;
      }

      currentSession.value = data;
      maxMinutes.value = data['max_minutes'] ?? 0;
      
      _showWaitingDialog('Connecting with ${partner['name'] ?? 'Astrologer'}...');
      
      // Join room to listen for partner_joined
      _joinRoom(currentSession['_id']);
    } else {
      final msg = ApiService.getMessage(res);
      final isLowBalance = (res?['low_balance'] == true) || 
                          msg.toLowerCase().contains('insufficient wallet balance') ||
                          msg.toLowerCase().contains('wallet balance');

      if (isLowBalance) {
        _showRechargeDialog(msg);
      } else {
        SnackbarUtil.error(msg);
      }
    }
  }

  Future<void> _resumeSession(String sessionId) async {
    currentSession.value = {'_id': sessionId};
    isLoading.value = true;
    final res = await _api.get('/customer/chat/messages/$sessionId');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map) {
        messages.value = List.from(data['messages'] ?? []);
        if (data['session'] != null) {
          final session = data['session'] as Map;
          currentSession.value = Map<String, dynamic>.from(session);
          
          // Sync timer if connected
          final status = session['status']?.toString().toLowerCase();
          if (status == 'connected' && session['started_at'] != null) {
            try {
              final startedAt = DateTime.parse(session['started_at'].toString()).toLocal();
              final now = DateTime.now();
              final diff = now.difference(startedAt).inSeconds;
              chatDuration.value = diff > 0 ? diff : 0;
              _startTimer();
            } catch (_) {}
          }
        }
      } else {
        messages.value = List.from(data ?? []);
      }
      if (!isReadOnly.value) {
        _joinRoom(sessionId);
      }
      _scrollToBottom();
    }
  }

  void _startTimer() {
    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      chatDuration.value++;
    });
  }

  Future<void> sendMessage(String text, {String? image, String messageType = 'text'}) async {
    if (isEnded.value) return;
    if (messageType == 'text' && text.trim().isEmpty) return;

    if (currentSession['_id'] != null) {
      // ✅ FIXED: Do NOT re-emit join_chat on every sendMessage — just emit the message directly
      // _joinRoom already handled at session start
    }

    final payload = {
      'session_id': currentSession['_id'],
      'sender_id': _customerId,
      'sender_type': 'customer',
      'text': text.trim(),
      'image': image ?? '',
      'message_type': messageType
    };

    _socket?.emit('send_message', payload);
  }

  Future<void> pickAndSendImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );

      if (file != null) {
        await _uploadAndSendImage(file);
      }
    } catch (e) {
      SnackbarUtil.error('Error picking image: $e');
    }
  }

  Future<void> _uploadAndSendImage(XFile file) async {
    isUploading.value = true;
    try {
      final String fileName = file.path.split('/').last;
      final dio.FormData formData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });

      final res = await _api.post(ApiConstants.upload, data: formData);

      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res);
        final imageUrl = data['full_url'] ?? '';
        if (imageUrl.isNotEmpty) {
          await sendMessage('', image: imageUrl, messageType: 'image');
        }
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      SnackbarUtil.error('Error uploading image: $e');
    } finally {
      isUploading.value = false;
    }
  }

  void _safePop() {
    try {
      Navigator.of(Get.context!).pop();
    } catch (e) {
      print('Safe pop error: $e');
      Get.back(); // Final fallback
    }
  }

  Future<void> endChat({String? reason}) async {
    if (isEnded.value) return;
    isEnded.value = true;
    _durationTimer?.cancel();

    final sessionId = currentSession['_id']?.toString();
    if (sessionId != null && sessionId.isNotEmpty) {
      Map<String, dynamic>? result;
      try {
        if (chatDuration.value > 0) {
          final effectiveReason = reason ?? 'completed';
          final res = await _api.post('/customer/chat/end', data: {
            'session_id': sessionId,
            'duration': chatDuration.value,
            'reason': effectiveReason
          });
          if (ApiService.isSuccess(res)) {
            result = ApiService.getData(res) as Map<String, dynamic>?;
          }
        } else {
          // If duration is 0, session never started. 
          // Avoid calling /end REST API as it triggers duration calculation and charging.
          // The socket emission below will notify the system.
          print('Chat: Cancelling unstarted session via socket only.');
        }
      } catch (_) {}
      if (chatDuration.value == 0) {
        _socket?.emit('cancel_chat_request', {'session_id': sessionId});
        _socket?.emit('end_chat', {'session_id': sessionId});
        _cleanupAndExit();
      } else {
        _socket?.emit('end_chat', {'session_id': sessionId});
        _showEndedDialog(result ?? {});
      }
    } else {
      _cleanupAndExit();
    }
  }

  void _exitChatScreen() {
    // Close any open dialogs first, then exit chat page
    if (Get.isDialogOpen == true) Get.back();
    // Pop until we exit the chat route
    final route = Get.currentRoute;
    if (route.contains('chat')) {
      Get.back();
    }
  }

  void _cleanupAndExit() {
    isEnded.value = true;
    _durationTimer?.cancel();
    _exitChatScreen();
  }

  void _showEndedDialog(Map data) {
    if (Get.isDialogOpen == true) Get.back(); // Close any open dialogs (like busy or recharge)
    
    final int durationSec = (data['duration'] ?? chatDuration.value) as int;
    final double totalCharge = (data['total_charge'] as num?)?.toDouble() ?? (data['amount_charged'] as num?)?.toDouble() ?? 0.0;
    final double balance = (data['customer_balance'] as num?)?.toDouble() ?? (data['wallet_balance'] as num?)?.toDouble() ?? 0.0;
    final String reason = data['reason'] ?? 'Session completed';
    final String displayReason = reason == 'insufficient_balance' 
        ? 'Session ended due to low balance' 
        : (reason == 'free_chat_limit' ? 'Free 1-minute offer ended' : reason);

    final String durationText = '${(durationSec ~/ 60).toString().padLeft(2, '0')}:${(durationSec % 60).toString().padLeft(2, '0')}';

    Get.defaultDialog(
      title: 'Chat Ended',
      content: Column(
        children: [
          if (displayReason != 'Session completed')
            Text(displayReason, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _summaryRow('Duration', durationText),
          _summaryRow('Amount Deducted', '₹${totalCharge.toStringAsFixed(2)}'),
          _summaryRow('Wallet Balance', '₹${balance.toStringAsFixed(2)}'),
        ],
      ),
      textConfirm: 'OK',
      onConfirm: () {
        if (Get.isRegistered<WalletController>()) {
          Get.find<WalletController>().walletBalance.value = balance;
        }
        Get.back(); // Close dialog
        _refreshStatusDependentData();
        
        if (reason == 'insufficient_balance' || reason == 'free_chat_limit') {
          _exitChatScreen(); // Exit first
          _showRechargeDialog(reason == 'free_chat_limit'
              ? 'Your ${maxMinutes.value}-minute free chat has ended. Please recharge your wallet to continue consulting.'
              : 'Your balance was insufficient to continue the chat. Please recharge your wallet.');
        } else if (reason == 'astrologer_declined') {
          _exitChatScreen(); // Exit first
          _showDeclinedDialog('The astrologer declined your chat request. Please try another astrologer.');
        } else {
          _showRatingDialog(); // Show rating, which exits chat after
        }
      },
      barrierDismissible: false,
    );
  }

  void _showDeclinedDialog(String message) {
    Get.defaultDialog(
      title: 'Request Declined',
      middleText: message,
      textConfirm: 'OK',
      onConfirm: () => _safePop(),
    );
  }

  Future<void> cancelQueue() async {
    // 1. Dismiss dialog immediately
    if (Get.isDialogOpen == true) Get.back();

    // 2. Exit chat screen immediately
    final route = Get.currentRoute;
    if (route.contains('chat')) {
      Get.back();
    }

    // 3. Fire API call in background
    if (queueId.value.isNotEmpty) {
      _api.post('/customer/chat/cancel-queue', data: {'queue_id': queueId.value})
          .catchError((_) => null);
    }
    isQueued.value = false;
  }

  void _showRechargeDialog(String message) {
    Get.defaultDialog(
      title: 'Low Balance',
      middleText: message,
      textConfirm: 'Recharge',
      textCancel: 'Close',
      onCancel: () {
        Get.back(); // Close the dialog
      },
      onConfirm: () {
        _safePop(); // Close dialog
        Get.toNamed(AppRoutes.recharge);
      },
    );
  }

  void _showWaitingDialog(String message) {
    Get.defaultDialog(
      title: 'Connecting...',
      content: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
      textCancel: 'Cancel',
      onCancel: () {
        if (isQueued.value) {
          cancelQueue();
        } else {
          endChat(reason: 'cancelled');
        }
      },
      barrierDismissible: false,
    );
  }

  void _showBusyDialog(dynamic minutes) {
    isBusy.value = true;
    if (Get.isDialogOpen == true) return;
    Get.defaultDialog(
      title: 'Astrologer is Busy',
      middleText: 'The astrologer is currently in another chat. Please wait about $minutes minutes. Your timer has not started yet.',
      barrierDismissible: false,
      textConfirm: 'Wait',
      onConfirm: () => _safePop(),
      textCancel: 'Exit',
      onCancel: () => endChat(),
    );
  }

  void _refreshStatusDependentData() {
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().refresh();
    }
    if (Get.isRegistered<AstrologerController>()) {
      final astrologerController = Get.find<AstrologerController>();
      astrologerController.loadAstrologers(refresh: true);
      final astrologerId = partner['_id']?.toString();
      if (astrologerId != null && astrologerId.isNotEmpty) {
        astrologerController.refreshSelectedAstrologer(astrologerId);
      }
    }
  }

  void _showRatingDialog() {
    int selectedRating = 5;
    final commentController = TextEditingController();

    Get.defaultDialog(
      title: 'Rate your Experience',
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              const Text('How was your chat with the astrologer?'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      index < selectedRating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 32,
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
            ],
          );
        },
      ),
      textConfirm: 'Submit',
      textCancel: 'Skip',
      onConfirm: () {
        submitReview(selectedRating, commentController.text.trim());
        Get.offAllNamed(AppRoutes.dashboard);
      },
      onCancel: () {
        Get.offAllNamed(AppRoutes.dashboard);
      },
      barrierDismissible: false,
    );
  }

  Future<void> submitReview(int rating, String comment) async {
    final res = await _api.post('/customer/review', data: {
      'astrologer_id': partner['_id'],
      'rating': rating,
      'comment': comment,
      'session_id': currentSession['_id'],
    });

    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Thank you for your feedback!');
    }
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
