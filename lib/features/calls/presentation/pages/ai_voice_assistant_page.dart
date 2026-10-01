import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/data/ai_astrologers_data.dart';
import '../../../../core/utils/gujarati_script_utils.dart';

class AIVoiceAssistantPage extends StatefulWidget {
  const AIVoiceAssistantPage({super.key});

  @override
  State<AIVoiceAssistantPage> createState() => _AIVoiceAssistantPageState();
}

class _AIVoiceAssistantPageState extends State<AIVoiceAssistantPage>
    with TickerProviderStateMixin {
  late Map<String, dynamic> _astrologer;
  late AnimationController _pulseController;
  late AnimationController _waveController;

  Timer? _callTimer;
  int _callDurationSeconds = 0;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  bool _isListening = false;
  bool _isAiSpeaking = true;

  String _currentDialogue = '';
  final List<Map<String, String>> _dialogueHistory = [];

  final List<String> _quickPrompts = [
    '💼 How is my career this year?',
    '❤️ When will I get married?',
    '💰 Tips for wealth & financial growth',
    '🪐 Is Shani Sade Sati affecting me?',
    '💎 Which gemstone is auspicious for me?',
    '🌟 Tell me today\'s planetary remedy',
  ];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is Map<String, dynamic>) {
      _astrologer = Map<String, dynamic>.from(args);
    } else if (args is Map) {
      _astrologer = Map<String, dynamic>.from(args);
    } else {
      _astrologer = AIAstrologersData.defaultAIAstrologers.first;
    }

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();

    _startCallTimer();
    _initGreeting();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callDurationSeconds++;
        });
      }
    });
  }

  void _initGreeting() {
    final name = _astrologer['name'] ?? 'AI Astrologer';
    final gender = _astrologer['gender'] ?? 'boy';
    final isBoy = gender == 'boy';

    final greeting = isBoy
        ? 'Pranam! I am $name, your AI Vedic Astrologer. I have analyzed cosmic alignments for you. What would you like to know about your kundali, career, or relationships?'
        : 'Namaste! I am $name, your AI Astro Guide. The stars and tarot cards are aligned in your favor today. Ask me any question to reveal cosmic answers.';

    setState(() {
      _currentDialogue = greeting;
      _dialogueHistory.add({'sender': 'ai', 'text': greeting});
      _isAiSpeaking = true;
    });

    // Simulate AI finishing speaking after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _isAiSpeaking = false;
        });
      }
    });
  }

  void _askPrompt(String prompt) {
    if (_isAiSpeaking) return;

    setState(() {
      _dialogueHistory.add({'sender': 'user', 'text': prompt});
      _isAiSpeaking = true;
      _isListening = false;
      _currentDialogue = 'Analyzing planetary charts for: "$prompt"...';
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      final answer = _generateAiVoiceResponse(prompt);
      setState(() {
        _currentDialogue = answer;
        _dialogueHistory.add({'sender': 'ai', 'text': answer});
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() {
            _isAiSpeaking = false;
          });
        }
      });
    });
  }

  String _generateAiVoiceResponse(String query) {
    final name = _astrologer['name'] ?? 'Astrologer';
    final q = query.toLowerCase();

    if (q.contains('career') || q.contains('job')) {
      return '$name says: Your 10th house of profession is illuminated by Jupiter\'s transit. A major career progression or job promotion is indicated over the coming months. Maintain focus and worship Lord Surya daily for success.';
    } else if (q.contains('marri') || q.contains('love') || q.contains('relationship')) {
      return '$name says: Venus occupies a harmonious angle in your chart, blessing your relationship prospects. For singles, an auspicious alliance arrives soon. For couples, peaceful understanding will flourish.';
    } else if (q.contains('wealth') || q.contains('money') || q.contains('financ')) {
      return '$name says: The 2nd and 11th houses signify steady financial inflow. Avoid impulsive speculative investments on Saturdays, and recite the Shree Suktam to attract sustained abundance.';
    } else if (q.contains('shani') || q.contains('sade sati')) {
      return '$name says: Saturn acts as a wise teacher in your horoscope. Even during challenging transits, offering mustard oil to Lord Shani on Saturdays and practicing truthfulness brings divine protection and stability.';
    } else if (q.contains('gemstone') || q.contains('ratna')) {
      return '$name says: Based on your planetary alignment, Yellow Sapphire (Pukhraj) or Blue Sapphire should be chosen only after precise lagna confirmation. Wearing a natural Rudraksha beads mala is immediately auspicious and safe.';
    }
    return '$name says: The cosmos has heard your prayer. Your planetary energies are harmonizing into a positive phase. Keep your intentions pure and perform a brief meditation each morning.';
  }

  void _toggleMic() {
    if (_isAiSpeaking) return;
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      // Simulate voice listening and auto response
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted || !_isListening) return;
        _askPrompt('How will my health and happiness be in the coming days?');
      });
    }
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  String _formatTimer(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final name = _astrologer['name']?.toString() ?? 'AI Astrologer';
    final isBoy = _astrologer['gender'] == 'boy';
    final profilePic = _astrologer['profile_pic']?.toString() ??
        _astrologer['profile_image']?.toString() ??
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400';

    return Scaffold(
      backgroundColor: const Color(0xFF0F0B1A),
      body: Stack(
        children: [
          // Background Cosmic Nebula Image with Blur
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: profilePic,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF130E26),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      const Color(0xFF0A0714).withValues(alpha: 0.85),
                      const Color(0xFF1A1230).withValues(alpha: 0.92),
                      const Color(0xFF090610).withValues(alpha: 0.98),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Main Call Interface
          SafeArea(
            child: Column(
              children: [
                _buildHeader(name, isBoy),
                SizedBox(height: 10.h),
                _buildCallTimer(),
                SizedBox(height: 20.h),
                _buildAvatarSection(profilePic, isBoy),
                SizedBox(height: 20.h),
                _buildAudioVisualizer(),
                SizedBox(height: 16.h),
                _buildDialogueBox(),
                SizedBox(height: 12.h),
                _buildQuickPrompts(),
                const Spacer(),
                _buildBottomControls(),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(String name, bool isBoy) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 32),
            onPressed: () => Get.back(),
          ),
          Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: (isBoy ? Colors.blueAccent : Colors.purpleAccent).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: (isBoy ? Colors.blueAccent : Colors.purpleAccent).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isBoy ? Icons.record_voice_over : Icons.spatial_audio_off,
                      color: Colors.white,
                      size: 14.sp,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      '${isBoy ? 'boy_tag'.tr : 'girl_tag'.tr} ${'ai_voice_assistant'.tr}'.toUpperCase(),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                GujaratiScriptUtils.toGujaratiName(name),
                style: AppTextStyles.h4.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          IconButton(
            icon: Icon(
              _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
              color: Colors.white70,
              size: 24.sp,
            ),
            onPressed: () {
              setState(() {
                _isSpeakerOn = !_isSpeakerOn;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCallTimer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF00E676),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            _formatTimer(_callDurationSeconds),
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            '• FREE AI CALL',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gold,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection(String profilePic, bool isBoy) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + (_pulseController.value * 0.08);
        final glowColor = isBoy ? Colors.cyanAccent : const Color(0xFFFF4081);

        return Stack(
          alignment: Alignment.center,
          children: [
            // Outermost Ripple Ring
            Container(
              width: 170.r * scale,
              height: 170.r * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: glowColor.withValues(alpha: 0.25 * (1 - _pulseController.value)),
                  width: 3,
                ),
              ),
            ),
            // Middle Ring
            Container(
              width: 145.r * scale,
              height: 145.r * scale,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: glowColor.withValues(alpha: 0.45 * (1 - _pulseController.value)),
                  width: 2.5,
                ),
              ),
            ),
            // Avatar
            Container(
              width: 120.r,
              height: 120.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: glowColor.withValues(alpha: 0.5),
                    blurRadius: 25,
                    spreadRadius: 4,
                  ),
                ],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: ClipOval(
                child: _buildAiAvatar(_astrologer, 120.r),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAudioVisualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        final isActive = _isAiSpeaking || _isListening;
        final barCount = 18;

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(barCount, (index) {
            double height = 8.h;
            if (isActive) {
              final phase = (_waveController.value * 2 * pi) + (index * 0.35);
              height = (sin(phase).abs() * 24.h) + 6.h;
            }
            return Container(
              margin: EdgeInsets.symmetric(horizontal: 2.5.w),
              width: 4.w,
              height: height,
              decoration: BoxDecoration(
                color: _isAiSpeaking
                    ? const Color(0xFFFFD54F)
                    : (_isListening ? const Color(0xFF00E676) : Colors.white24),
                borderRadius: BorderRadius.circular(4.r),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildDialogueBox() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w),
      padding: EdgeInsets.all(16.w),
      constraints: BoxConstraints(minHeight: 80.h, maxHeight: 110.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.15),
        ),
      ),
      child: SingleChildScrollView(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              _isAiSpeaking ? Icons.auto_awesome : (_isListening ? Icons.mic : Icons.chat),
              color: _isAiSpeaking ? const Color(0xFFFFD54F) : Colors.cyanAccent,
              size: 20.sp,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                _currentDialogue,
                style: AppTextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  height: 1.4,
                  fontSize: 13.sp,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPrompts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 4.h),
          child: Text(
            'TAP A QUESTION TO ASK THE AI VOICE ASSISTANT:',
            style: AppTextStyles.caption.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
              fontSize: 10.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
        SizedBox(
          height: 40.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            itemCount: _quickPrompts.length,
            itemBuilder: (context, index) {
              final prompt = _quickPrompts[index];
              return GestureDetector(
                onTap: () => _askPrompt(prompt),
                child: Container(
                  margin: EdgeInsets.only(right: 8.w),
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      prompt,
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mute Button
          _buildCircleButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            isActive: _isMuted,
            onTap: () {
              setState(() {
                _isMuted = !_isMuted;
              });
            },
          ),

          // Tap to Speak / Listening Button
          GestureDetector(
            onTap: _toggleMic,
            child: Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: _isListening
                      ? [const Color(0xFF00E676), const Color(0xFF00B0FF)]
                      : [AppColors.primary, const Color(0xFFFF8E53)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? const Color(0xFF00E676) : AppColors.primary)
                        .withValues(alpha: 0.45),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.graphic_eq : Icons.mic_none,
                color: Colors.white,
                size: 34.sp,
              ),
            ),
          ),

          // End Call Button
          _buildCircleButton(
            icon: Icons.call_end,
            label: 'End Call',
            color: Colors.redAccent,
            onTap: () {
              Get.back();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
    Color? color,
  }) {
    final btnColor = color ?? (isActive ? Colors.redAccent : Colors.white.withValues(alpha: 0.15));

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: btnColor,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 24.sp),
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: Colors.white70,
            fontSize: 11.sp,
          ),
        ),
      ],
    );
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
            bottom: 4,
            right: 4,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.5),
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
