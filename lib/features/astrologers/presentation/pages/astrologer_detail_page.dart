import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:astrology_user/core/constants/api_constants.dart';
import 'package:astrology_user/core/utils/astrologer_utils.dart';
import 'package:astrology_user/core/utils/name_transliteration_utils.dart';
import 'package:astrology_user/features/astrologers/presentation/controllers/astrologer_controller.dart';
import 'package:astrology_user/features/calls/presentation/controllers/call_controller.dart';
import 'package:astrology_user/features/chat/presentation/controllers/chat_controller.dart';
import 'package:astrology_user/core/utils/snackbar_util.dart';
import 'package:astrology_user/config/routes/app_routes.dart';

import 'package:astrology_user/features/home/presentation/controllers/home_controller.dart';

class AstrologerDetailPage extends StatefulWidget {
  const AstrologerDetailPage({super.key});

  @override
  State<AstrologerDetailPage> createState() => _AstrologerDetailPageState();
}

class _AstrologerDetailPageState extends State<AstrologerDetailPage> {
  final AstrologerController controller = Get.find<AstrologerController>();

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    final astrologerId = (args is Map) ? args['_id']?.toString() : null;

    // Immediately synchronize AI state from HomeController if registered
    if (Get.isRegistered<HomeController>()) {
      final homeCtrl = Get.find<HomeController>();
      controller.isAiFreeAvailable.value = homeCtrl.isAiFreeAvailable.value;
      controller.aiChatPrice.value = homeCtrl.aiChatPrice.value;
      controller.isAiChatEnabled.value = homeCtrl.isAiChatEnabled.value;
      controller.isAiFirstChatFree.value = homeCtrl.isAiFirstChatFree.value;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchAiChatConfigAndEligibility();
      if (astrologerId != null && astrologerId.isNotEmpty) {
        controller.refreshSelectedAstrologer(astrologerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Read directly from Get.arguments — always available, no controller lifecycle issues
    final args = Get.arguments;
    final Map initialData = (args is Map) ? args : {};
    final String? astrologerId = initialData['_id']?.toString();

    if (astrologerId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('astrologer_detail_title'.tr)),
        body: Center(child: Text('no_astrologer_data'.tr)),
      );
    }

    return Obx(() {
      final selected = controller.selectedAstrologer;
      final astrologer =
          (selected.isNotEmpty && selected['_id']?.toString() == astrologerId)
          ? Map<String, dynamic>.from(selected)
          : controller.astrologers.firstWhere(
              (a) => a['_id'] == astrologerId,
              orElse: () => initialData,
            );

      return Scaffold(
        body: CustomScrollView(
          slivers: [
            _buildAppBar(astrologer),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBasicInfo(astrologer),
                  _buildStats(astrologer),
                  _buildAboutSection(astrologer),
                  _buildSkillsSection(astrologer),
                  _buildReviewsSection(astrologer),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: _buildBottomBarDirect(astrologer),
      );
    });
  }

  // Helper to safely extract values from the API response
  String? _id(Map a) => (a['_id'] ?? a['id'])?.toString();
  String _name(Map a) => AstrologerUtils.getLocalizedAstrologerName(a);
  String _specialization(Map a) {
    return AstrologerUtils.getLocalizedAstrologerSpecialization(a);
  }

  String _experience(Map a) {
    final exp = a['experience'] ?? a['experience_years'];
    if (exp == null) return 'N/A';
    return '${NameTransliterationUtils.toLocalizedNumber(exp)} yr';
  }

  num _price(Map a) =>
      (a['pricePerMinute'] ??
              a['price'] ??
              a['call_price'] ??
              a['chat_price'] ??
              0)
          as num;
  bool _isOnline(Map a) => (a['isOnline'] ?? a['is_online']) as bool? ?? false;
  bool _isChatEnabled(Map a) =>
      (a['isChatEnabled'] ?? a['is_chat_available']) as bool? ?? false;
  bool _isCallEnabled(Map a) =>
      (a['isCallEnabled'] ?? a['is_call_available']) as bool? ?? false;
  bool _isVideoCallEnabled(Map a) =>
      (a['isVideoCallEnabled'] ?? a['is_video_call_available']) as bool? ??
      false;
  num _rating(Map a) => (a['rating'] ?? 0) as num;
  num _chatPrice(Map a) => (a['chatPrice'] ?? _price(a)) as num;
  num _voicePrice(Map a) => (a['voicePrice'] ?? _price(a)) as num;
  num _videoPrice(Map a) => (a['videoPrice'] ?? _price(a)) as num;
  String _bio(Map a) => AstrologerUtils.getLocalizedAstrologerBio(a);
  String? _profilePic(Map a) => AstrologerUtils.getAstrologerImage(a);
  List<dynamic> _skills(Map a) {
    final s = a['skills'];
    if (s is List) {
      return s.map((e) => NameTransliterationUtils.toLocalizedSpecialization(e.toString())).toList();
    }
    return [];
  }

  List<Map<String, dynamic>> _reviews(Map a) {
    final r = a['reviews'];
    return r is List ? r.whereType<Map<String, dynamic>>().toList() : [];
  }

  Widget _buildFollowButton() {
    return Obx(() {
      final astro = controller.selectedAstrologer;
      final isFollowing = controller.isFollowing(astro);
      final id = _id(astro);
      return GestureDetector(
        onTap: () {
          if (id != null && id.isNotEmpty) {
            controller.toggleFollow(id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: isFollowing ? Colors.white : Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.white, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isFollowing ? Icons.favorite : Icons.favorite_border,
                color: isFollowing ? AppColors.primary : Colors.white,
                size: 18.sp,
              ),
              SizedBox(width: 6.w),
              Text(
                isFollowing ? 'Unfollow' : 'Follow',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: isFollowing ? AppColors.primary : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildAppBar(Map astrologer) {
    final bool isAi = astrologer['is_ai'] == true ||
        (astrologer['_id']?.toString().startsWith('6aa00000000000000000000') ?? false);
    final pic = _profilePic(astrologer);
    return SliverAppBar(
      expandedHeight: 250.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 90.w,
                  height: 90.w,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  padding: EdgeInsets.all(2.w),
                  child: ClipOval(
                    child: isAi
                        ? _buildAiAvatar(astrologer, 90.w)
                        : (pic != null && pic.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: ApiConstants.resolveImage(pic),
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[200],
                                  child: Icon(
                                    Icons.person,
                                    size: 45.sp,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              )
                            : Container(
                                color: Colors.grey[200],
                                child: Icon(
                                  Icons.person,
                                  size: 45.sp,
                                  color: Colors.grey[500],
                                ),
                              )),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _name(astrologer),
                  style: AppTextStyles.h3.copyWith(color: Colors.white),
                ),
                Text(
                  _specialization(astrologer),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 10.h),
                _buildFollowButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfo(Map astrologer) {
    final followersCount = controller.getFollowersCount(astrologer);
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(Icons.star, '${_rating(astrologer)}', 'rating'.tr),
          _buildInfoItem(
            Icons.work_outline,
            _experience(astrologer),
            'experience'.tr,
          ),
          _buildInfoItem(
            Icons.people_outline,
            '${astrologer['totalConsultations'] ?? 0}+',
            'consultations'.tr,
          ),
          _buildInfoItem(
            Icons.favorite_rounded,
            '$followersCount',
            'Followers',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24.sp),
        SizedBox(height: 8.h),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(label, style: AppTextStyles.caption),
      ],
    );
  }

  Widget _buildStats(Map astrologer) {
    final languages = astrologer['languages'];
    final languageText = (languages is List && languages.isNotEmpty)
        ? languages.join(', ')
        : 'Hindi, English';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('languages'.tr, style: AppTextStyles.bodySmall),
              SizedBox(height: 4.h),
              Text(
                languageText,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _isOnline(astrologer) ? Colors.green : Colors.grey,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              _isOnline(astrologer) ? 'online'.tr : 'offline'.tr,
              style: AppTextStyles.caption.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(Map astrologer) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('about'.tr, style: AppTextStyles.h4),
          SizedBox(height: 8.h),
          Text(_bio(astrologer), style: AppTextStyles.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(Map astrologer) {
    final skills = _skills(astrologer);
    if (skills.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('skills'.tr, style: AppTextStyles.h4),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: skills.map((skill) {
              return Chip(
                label: Text(skill.toString()),
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.primary,
                ),
              );
            }).toList(),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(Map astrologer) {
    final reviews = _reviews(astrologer);
    if (reviews.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('reviews'.tr, style: AppTextStyles.h4),
            SizedBox(height: 8.h),
            Text('no_reviews_yet'.tr, style: AppTextStyles.bodySmall),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('reviews'.tr, style: AppTextStyles.h4),
              TextButton(
                onPressed: () {},
                child: Text(
                  'view_all'.tr,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ...reviews.map(_buildReviewCard).toList(),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map review) {
    final rating = review['rating'] ?? 0;
    final comment = (review['comment'] as String?)?.trim();
    final dateRaw = review['createdAt'] as String?;
    String dateText = 'Recent';
    if (dateRaw != null && dateRaw.contains('T')) {
      dateText = dateRaw.split('T').first;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 20.r, backgroundColor: AppColors.primary),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'verified_user'.tr,
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < rating
                              ? Colors.amber
                              : Colors.grey.withValues(alpha: 0.4),
                          size: 14.sp,
                        );
                      }),
                    ),
                  ],
                ),
              ),
              Text(
                dateText == 'Recent' ? 'recent'.tr : dateText,
                style: AppTextStyles.caption,
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            (comment != null && comment.isNotEmpty)
                ? comment
                : 'happy_consultation'.tr,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBarDirect(Map astrologer) {
    final bool isAi = astrologer['is_ai'] == true ||
        (astrologer['_id']?.toString().startsWith('6aa00000000000000000000') ?? false);
    final online = isAi ? true : _isOnline(astrologer);
    final chatEnabled = isAi ? true : _isChatEnabled(astrologer);
    final callEnabled = isAi ? true : _isCallEnabled(astrologer);
    final videoCallEnabled = isAi ? false : _isVideoCallEnabled(astrologer);

    return SafeArea(
      top: false,
      bottom: true,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chat Row
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isAi)
                      Obx(() {
                        final isFree = controller.isAiFreeAvailable.value;
                        return Container(
                          margin: EdgeInsets.only(bottom: 2.h),
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: isFree ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(4.r),
                            border: Border.all(
                              color: isFree ? const Color(0xFF81C784) : const Color(0xFFFFB74D),
                              width: 0.5.w,
                            ),
                          ),
                          child: Text(
                            isFree ? 'Your first chat is FREE' : 'AI Astrologer Chat',
                            style: TextStyle(
                              color: isFree ? const Color(0xFF2E7D32) : const Color(0xFFE65100),
                              fontSize: 9.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      })
                    else
                      Obx(() {
                        if (controller.isFreeChatEligible.value) {
                          return Container(
                            margin: EdgeInsets.only(bottom: 2.h),
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3E0),
                              borderRadius: BorderRadius.circular(4.r),
                              border: Border.all(color: const Color(0xFFFFB74D), width: 0.5.w),
                            ),
                            child: Text(
                              '${controller.freeChatDurationMinutes.value} Min Free Chat',
                              style: TextStyle(
                                color: const Color(0xFFE65100),
                                fontSize: 9.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      }),
                    Text('chat_fee'.tr, style: AppTextStyles.caption),
                    if (isAi)
                      Obx(() {
                        final isFree = controller.isAiFreeAvailable.value;
                        final price = controller.aiChatPrice.value;
                        return RichText(
                          text: TextSpan(
                            children: [
                              if (isFree) ...[
                                TextSpan(
                                  text: '₹$price ',
                                  style: AppTextStyles.h4.copyWith(
                                    color: Colors.grey,
                                    decoration: TextDecoration.lineThrough,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                TextSpan(
                                  text: 'FREE',
                                  style: AppTextStyles.h4.copyWith(
                                    color: const Color(0xFF2E7D32),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ] else ...[
                                TextSpan(
                                  text: '₹$price',
                                  style: AppTextStyles.h4.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: ' / Chat',
                                  style: AppTextStyles.caption.copyWith(fontSize: 12.sp),
                                ),
                              ],
                            ],
                          ),
                        );
                      })
                    else
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '₹${_chatPrice(astrologer)}',
                              style: AppTextStyles.h4.copyWith(color: AppColors.primary),
                            ),
                            TextSpan(
                              text: '/min',
                              style: AppTextStyles.caption.copyWith(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              Obx(() {
                final isFree = controller.isAiFreeAvailable.value;
                final aiPrice = controller.aiChatPrice.value;
                final isAiActive = controller.isAiChatEnabled.value;
                final canChat = isAi ? isAiActive : (online && chatEnabled);

                return Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: canChat
                          ? (isAi && isFree
                              ? const LinearGradient(colors: [Color(0xFF2E7D32), Color(0xFF43A047)])
                              : AppColors.secondaryGradient)
                          : null,
                      color: canChat ? null : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: canChat
                          ? [
                              BoxShadow(
                                color: (isAi && isFree ? Colors.green : AppColors.secondary).withValues(alpha: 0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          : null,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          if (!canChat) {
                            SnackbarUtil.error(isAi
                                ? 'AI Astrologer Chat is currently unavailable. Please try again later.'
                                : 'Astrologer is not available for chat right now.');
                            return;
                          }
                          if (!Get.isRegistered<ChatController>()) {
                            Get.put(ChatController());
                          }
                          final chatCtrl = Get.find<ChatController>();
                          chatCtrl.partner.assignAll(astrologer);

                          if (isAi && !isFree) {
                            final walletBal = controller.customerWalletBalance.value;
                            if (walletBal < aiPrice) {
                              Get.defaultDialog(
                                title: 'Insufficient Balance',
                                middleText:
                                    'AI Astrologer consultation fee is ₹$aiPrice.\nYour wallet balance is ₹${walletBal.toStringAsFixed(0)}.\nPlease recharge to continue.',
                                textConfirm: 'Recharge',
                                textCancel: 'Cancel',
                                confirmTextColor: Colors.white,
                                buttonColor: AppColors.primary,
                                onConfirm: () {
                                  Get.back();
                                  Get.toNamed(AppRoutes.recharge);
                                },
                              );
                              return;
                            }

                            Get.defaultDialog(
                              title: 'AI Astrologer Chat',
                              middleText:
                                  'Start chat with ${astrologer['name'] ?? 'AI Astrologer'} for ₹$aiPrice?\n(Current Wallet: ₹${walletBal.toStringAsFixed(0)})',
                              textConfirm: 'Start Chat',
                              textCancel: 'Cancel',
                              confirmTextColor: Colors.white,
                              buttonColor: AppColors.secondary,
                              onConfirm: () {
                                Get.back();
                                chatCtrl.initiateChat();
                              },
                            );
                            return;
                          }

                          chatCtrl.initiateChat();
                        },
                        borderRadius: BorderRadius.circular(16.r),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isAi ? Icons.auto_awesome : Icons.chat_bubble_rounded,
                                size: 18.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                isAi
                                    ? (!isAiActive
                                        ? 'UNAVAILABLE'
                                        : (isFree ? 'START FREE CHAT' : 'START CHAT (₹$aiPrice)'))
                                    : 'chat'.tr.toUpperCase(),
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ],
          ),
          SizedBox(height: 16.h),
          // Call Row: Completely hidden for AI Astrologers (AI Astrologer is CHAT ONLY)
          if (!isAi)
            Row(
              children: [
                _buildCallButton(
                  icon: Icons.call_rounded,
                  label: 'voice_call'.tr,
                  price: _voicePrice(astrologer),
                  isEnabled: online && callEnabled,
                  color: AppColors.primary,
                  gradient: AppColors.primaryGradient,
                  onTap: () {
                    if (!Get.isRegistered<CallController>()) {
                      Get.put(CallController());
                    }
                    Get.find<CallController>().partner.value = astrologer;
                    Get.find<CallController>().initiateCall(astrologer['_id'].toString());
                  },
                ),
                SizedBox(width: 12.w),
                _buildCallButton(
                  icon: Icons.videocam_rounded,
                  label: 'video_call'.tr,
                  price: _videoPrice(astrologer),
                  isEnabled: online && videoCallEnabled,
                  color: Colors.purple,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E24AA), Color(0xFFD81B60)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  onTap: () {
                    if (!Get.isRegistered<CallController>()) {
                      Get.put(CallController());
                    }
                    Get.find<CallController>().partner.value = astrologer;
                    Get.find<CallController>().initiateCall(
                      astrologer['_id'].toString(),
                      type: 'video_call',
                    );
                  },
                ),
              ],
            ),
        ],
      ),
    ),
  );
}

  Widget _buildCallButton({
    required IconData icon,
    required String label,
    required num price,
    required bool isEnabled,
    required Color color,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: isEnabled ? gradient : null,
              color: isEnabled ? null : Colors.grey[200],
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: isEnabled ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (!isEnabled) {
                    SnackbarUtil.error('Astrologer is not available right now.');
                    return;
                  }
                  onTap();
                },
                borderRadius: BorderRadius.circular(16.r),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, size: 20.sp, color: isEnabled ? Colors.white : Colors.grey),
                      SizedBox(width: 6.w),
                      Text(
                        label,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isEnabled ? Colors.white : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            price == 0 ? 'FREE' : '₹$price/min',
            style: AppTextStyles.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: isEnabled ? AppColors.textPrimary : Colors.grey,
            ),
          ),
        ],
      ),
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
