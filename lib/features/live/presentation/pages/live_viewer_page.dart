import 'dart:async';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:astrology_user/core/constants/agora_constants.dart';
import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:astrology_user/core/constants/app_constants.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/core/utils/snackbar_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class LiveViewerPage extends StatefulWidget {
  const LiveViewerPage({super.key});

  @override
  State<LiveViewerPage> createState() => _LiveViewerPageState();
}

class _LiveViewerPageState extends State<LiveViewerPage> {
  RtcEngine? _engine;
  IO.Socket? _socket;
  bool _socketConnected = false;
  bool _chatVisible = true; // Local-only: hide/show chat without affecting others.
  bool _inLiveRoom = false; // Best-effort room membership flag (local only).
  bool _endDialogShown = false;
  bool _leaving = false;

  int? _remoteUid;

  Timer? _countdownTimer;
  int _countdown = 3;

  bool _muteAudio = false;
  bool _joined = false;
  int _uid = 0;

  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _chatScrollController = ScrollController();

  String _streamId = '';
  String _channel = '';
  String _token = '';
  int _viewers = 0;

  String _meId = '';
  String _meName = '';

  Map<String, dynamic> _stream = {};

  @override
  void initState() {
    super.initState();
    _loadArgs();
    _loadMe().then((_) {
      _initSocket();
      _initAgora();
    });
  }

  void _loadArgs() {
    final args = Get.arguments as Map?;
    final stream = (args?['stream'] as Map?)?.cast<String, dynamic>() ?? {};
    final join = (args?['join'] as Map?)?.cast<String, dynamic>() ?? {};

    _stream = stream;
    _streamId = (stream['_id'] ?? '').toString();
    _channel = (join['channel'] ?? '').toString();
    _token = (join['token'] ?? '').toString();
    _viewers = (join['viewers_count'] as num?)?.toInt() ?? 0;
    final rawUid = join['uid'];
    _uid = (rawUid is num) ? rawUid.toInt() : int.tryParse(rawUid?.toString() ?? '') ?? 0;
  }

  Future<void> _loadMe() async {
    final prefs = await SharedPreferences.getInstance();
    _meId = prefs.getString(AppConstants.keyUserId) ?? '';
    _meName = prefs.getString(AppConstants.keyUserName) ?? 'User';
  }

  void _initSocket() {
    if (_streamId.isEmpty) return;

    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).disableAutoConnect().build(),
    );

    _socket?.onConnect((_) {
      debugPrint('Socket(live viewer) connected id=${_socket?.id}');
      if (mounted) setState(() => _socketConnected = true);
      _socket?.emit('join_live_room', {'live_stream_id': _streamId});
    });

    _socket?.on('joined_live_room', (data) {
      debugPrint('Socket(live viewer) joined_live_room: $data');
      _inLiveRoom = true;
      if (mounted) setState(() {});
    });

    _socket?.on('left_live_room', (data) {
      debugPrint('Socket(live viewer) left_live_room: $data');
      _inLiveRoom = false;
      if (mounted) setState(() {});
    });

    _socket?.on('live_ended', (data) {
      debugPrint('Socket(live viewer) live_ended: $data');
      _handleStreamEnded();
    });

    _socket?.onDisconnect((_) {
      debugPrint('Socket(live viewer) disconnected');
      _inLiveRoom = false;
      if (mounted) setState(() => _socketConnected = false);
    });

    _socket?.onConnectError((err) {
      debugPrint('Socket(live viewer) connectError: $err');
      _inLiveRoom = false;
      if (mounted) setState(() => _socketConnected = false);
    });

    _socket?.onError((err) {
      debugPrint('Socket(live viewer) error: $err');
    });

    _socket?.on('receive_live_message', (data) {
      if (data is Map) {
        debugPrint('Socket(live viewer) message: $data');
        final msg = Map<String, dynamic>.from(data);
        // Always keep a local history, but only rebuild UI if chat is visible.
        if (_chatVisible) {
          if (!mounted) return;
          setState(() => _messages.add(msg));
          _scrollChatToBottom();
        } else {
          _messages.add(msg);
        }
      }
    });

    _socket?.connect();
  }

  Future<void> _initAgora() async {
    if (_channel.isEmpty) {
      SnackbarUtil.error('Missing channel. Please try again.');
      return;
    }
    if (_token.isEmpty) {
      SnackbarUtil.error('Missing Agora token. Please try again.');
      return;
    }

    final engine = createAgoraRtcEngine();
    await engine.initialize(const RtcEngineContext(appId: AgoraConstants.appId));

    // Register after initialize so callbacks always fire (SDKs may reset handlers on init).
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (connection, elapsed) {
          debugPrint('Agora(audience) joined channel=${connection.channelId} uid=${connection.localUid} elapsed=$elapsed');
          if (mounted) {
            setState(() {
              _joined = true;
              // If we joined with uid=0, Agora assigns a uid; store for debugging.
              _uid = connection.localUid ?? _uid;
            });
          }
        },
        onConnectionStateChanged: (_, state, reason) {
          debugPrint('Agora(audience) connectionState=$state reason=$reason');
          if (state == ConnectionStateType.connectionStateFailed) {
            SnackbarUtil.error('Live connection failed: $reason');
          }
        },
        onUserJoined: (_, uid, __) {
          debugPrint('Agora(audience) remote user joined uid=$uid');
          if (!mounted) return;
          setState(() => _remoteUid = uid);
        },
        onUserOffline: (_, uid, __) {
          debugPrint('Agora(audience) remote user offline uid=$uid');
          if (_remoteUid == uid) {
            if (!mounted) return;
            setState(() => _remoteUid = null);
            _handleStreamEnded();
          }
        },
        onRemoteVideoStateChanged: (_, remoteUid, state, reason, elapsed) {
          debugPrint(
              'Agora(audience) remoteVideo uid=$remoteUid state=$state reason=$reason elapsed=$elapsed');
        },
        onError: (err, msg) {
          debugPrint('Agora(audience) error=$err msg=$msg');
          SnackbarUtil.error('Agora error: $err $msg');
        },
      ),
    );
    await engine.setChannelProfile(ChannelProfileType.channelProfileLiveBroadcasting);
    await engine.setClientRole(role: ClientRoleType.clientRoleAudience);
    await engine.enableVideo();
    await engine.enableAudio();
    // Audience should never publish local tracks (YouTube-like experience).
    await engine.enableLocalAudio(false);
    await engine.enableLocalVideo(false);
    await engine.muteLocalAudioStream(true);
    await engine.muteLocalVideoStream(true);

    if (!mounted) {
      await engine.release();
      return;
    }

    setState(() => _engine = engine);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    setState(() => _countdown = 3);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_countdown <= 1) {
        timer.cancel();
        setState(() => _countdown = 0);
        await _joinChannel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _joinChannel() async {
    if (_engine == null) return;
    debugPrint('Agora(audience) joining channel=$_channel uid=$_uid tokenLen=${_token.length}');
    await _engine!.joinChannel(
      token: _token,
      channelId: _channel,
      uid: _uid,
      options: const ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        clientRoleType: ClientRoleType.clientRoleAudience,
        publishCameraTrack: false,
        publishMicrophoneTrack: false,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
      ),
    );
  }

  void _scrollChatToBottom() {
    Future.delayed(const Duration(milliseconds: 50), () {
      if (!mounted) return;
      if (!_chatScrollController.hasClients) return;
      _chatScrollController.animateTo(
        _chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  void _sendMessage() {
    if (!_chatVisible) return;
    final text = _messageController.text.trim();
    if (text.isEmpty || _socket == null) return;

    // If we haven't joined the live room for some reason, try again (idempotent).
    if (!_inLiveRoom && _streamId.isNotEmpty) {
      _socket?.emit('join_live_room', {'live_stream_id': _streamId});
    }

    _socket?.emit('send_live_message', {
      'live_stream_id': _streamId,
      'text': text,
      'sender_id': _meId,
      'sender_type': 'customer',
      'sender_name': _meName,
      'sender_profile_pic': '',
    });

    _messageController.clear();
  }

  void _toggleChatVisible() {
    setState(() => _chatVisible = !_chatVisible);
    if (_chatVisible) _scrollChatToBottom();
  }

  Future<void> _handleStreamEnded() async {
    if (_leaving) return;
    if (_endDialogShown) return;
    _endDialogShown = true;
    _countdownTimer?.cancel();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Live Ended'),
          content: const Text('This live stream has ended.'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(ctx).pop();
                await Future.delayed(const Duration(milliseconds: 80));
                await _leave();
              },
              child: const Text('Watch Other'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _toggleMuteAudio() async {
    if (_engine == null) return;
    final next = !_muteAudio;
    await _engine!.muteAllRemoteAudioStreams(next);
    setState(() => _muteAudio = next);
  }

  Future<void> _leave() async {
    if (_leaving) return;
    _leaving = true;
    _countdownTimer?.cancel();

    // 1. Immediately exit the screen
    if (mounted) Get.back();

    // 2. Perform network and Agora cleanup in the background asynchronously
    try {
      _socket?.emit('leave_live_room', {'live_stream_id': _streamId});
      _socket?.disconnect();
    } catch (_) {}
    _socket = null;

    final tempEngine = _engine;
    _engine = null;
    if (tempEngine != null) {
      try {
        tempEngine.leaveChannel();
        tempEngine.release();
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _messageController.dispose();
    _chatScrollController.dispose();
    _socket?.disconnect();
    _engine?.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final astrologer = (_stream['astrologer_id'] as Map?)?.cast<String, dynamic>() ?? {};
    final name = astrologer['name']?.toString().trim().isNotEmpty == true
        ? astrologer['name'].toString()
        : (astrologer['personal_details'] is Map
            ? astrologer['personal_details']['name']?.toString() ?? 'Astrologer'
            : 'Astrologer');

    final profileImage = astrologer['profile_pic']?.toString().trim().isNotEmpty == true
        ? astrologer['profile_pic'].toString()
        : (astrologer['personal_details'] is Map
            ? astrologer['personal_details']['profile_image']?.toString() ?? ''
            : '');

    final title = (_stream['title']?.toString().trim().isNotEmpty == true)
        ? _stream['title'].toString()
        : 'Live Session';

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_engine != null && _remoteUid != null)
              AgoraVideoView(
                controller: VideoViewController.remote(
                  rtcEngine: _engine!,
                  canvas: VideoCanvas(uid: _remoteUid),
                  connection: RtcConnection(channelId: _channel),
                ),
              )
            else
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.live_tv, color: Colors.white24, size: 160.sp),
                    SizedBox(height: 10.h),
                    Text(
                      _joined ? 'Waiting for host video…' : 'Connecting…',
                      style: AppTextStyles.bodyMedium.copyWith(color: Colors.white54),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Top bar
            Positioned(
              top: 20.h,
              left: 12.w,
              right: 12.w,
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, color: Colors.white, size: 8.sp),
                        SizedBox(width: 6.w),
                        Text(
                          'LIVE',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 10.w),
                  InkWell(
                    onTap: _toggleChatVisible,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7.w,
                            height: 7.w,
                            decoration: BoxDecoration(
                              color: !_socketConnected
                                  ? Colors.white38
                                  : (_inLiveRoom ? Colors.greenAccent : Colors.orangeAccent),
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(
                            _chatVisible ? Icons.chat_bubble : Icons.chat_bubble_outline,
                            color: Colors.white70,
                            size: 14.sp,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            _chatVisible ? 'CHAT ON' : 'CHAT OFF',
                            style: AppTextStyles.caption.copyWith(
                              color: _chatVisible ? Colors.greenAccent : Colors.white70,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Icon(Icons.visibility, color: Colors.white70, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    _viewers.toString(),
                    style: AppTextStyles.caption.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _leave,
                    child: Padding(
                      padding: EdgeInsets.all(10.w),
                      child: Icon(Icons.close, color: Colors.white, size: 28.sp),
                    ),
                  ),
                ],
              ),
            ),

            // Host card
            Positioned(
              top: 52.h,
              left: 12.w,
              right: 12.w,
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18.r,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.14),
                      backgroundImage: profileImage.isNotEmpty
                          ? CachedNetworkImageProvider(ApiConstants.resolveImage(profileImage))
                          : null,
                      child: profileImage.isEmpty
                          ? Icon(Icons.person, color: AppColors.primary, size: 18.sp)
                          : null,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            title,
                            style: AppTextStyles.caption.copyWith(color: Colors.white70),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Chat overlay
            if (_chatVisible)
              Positioned(
                bottom: 140.h,
                left: 12.w,
                right: 12.w,
                height: 240.h,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black],
                      stops: [0.0, 0.25],
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.dstIn,
                  child: ListView.builder(
                    controller: _chatScrollController,
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final name = (msg['sender_name'] ?? 'User').toString();
                      final text = (msg['text'] ?? '').toString();
                      final isHost = msg['sender_type'] == 'astrologer' || msg['sender_type'] == 'partner';
                      
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 6.h),
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(12.r),
                            border: isHost 
                                ? Border.all(color: Colors.amber.withValues(alpha: 0.6), width: 1.r)
                                : null,
                          ),
                          child: RichText(
                            text: TextSpan(
                              children: [
                                if (isHost) ...[
                                  WidgetSpan(
                                    alignment: PlaceholderAlignment.middle,
                                    child: Icon(Icons.stars, color: Colors.amber, size: 14.sp),
                                  ),
                                  const TextSpan(text: ' '),
                                ],
                                TextSpan(
                                  text: '$name: ',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: isHost ? Colors.amberAccent : Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: text,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

            // Controls + input
            Positioned(
              bottom: 14.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_chatVisible) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: 'Chat…',
                              hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                              filled: true,
                              fillColor: Colors.black54,
                              contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24.r),
                                borderSide: BorderSide.none,
                              ),
                            ),
                            onSubmitted: (_) => _sendMessage(),
                            enabled: _countdown == 0,
                          ),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                          child: IconButton(
                            icon: Icon(Icons.send, color: Colors.white, size: 22.sp),
                            onPressed: _countdown == 0 ? _sendMessage : null,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12.h),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ControlButton(
                        icon: _muteAudio ? Icons.volume_off : Icons.volume_up,
                        onPressed: _toggleMuteAudio,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            if (_countdown > 0)
              Positioned.fill(
                child: Container(
                  color: Colors.black87,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _countdown.toString(),
                          style: TextStyle(
                            fontSize: 86.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          'Joining live…',
                          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: onPressed,
      ),
    );
  }
}
