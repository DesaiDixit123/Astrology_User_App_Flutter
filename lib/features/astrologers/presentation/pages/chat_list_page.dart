import 'package:astrology_user/core/utils/gujarati_script_utils.dart';
import 'package:astrology_user/core/utils/astrologer_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<Map> chatHistory = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    await Future.delayed(const Duration(milliseconds: 250));
    chatHistory = [
      {
        '_id': 'cons_201',
        'type': 'Chat',
        'status': 'InProgress',
        'updatedAt': DateTime.now().toUtc().toIso8601String(),
        'partner': {
          '_id': 'partner_1',
          'name': 'Shloka Patel',
          'profilePic': 'https://i.pravatar.cc/150?img=12',
        },
      },
      {
        '_id': 'cons_202',
        'type': 'Chat',
        'status': 'Completed',
        'updatedAt': DateTime.now()
            .subtract(const Duration(days: 1))
            .toUtc()
            .toIso8601String(),
        'partner': {
          '_id': 'partner_2',
          'name': 'Tarot Sneha',
          'profilePic': 'https://i.pravatar.cc/150?img=21',
        },
      },
    ];
    if (mounted) setState(() => isLoading = false);
  }

  String _partnerName(Map c) {
    return AstrologerUtils.getLocalizedAstrologerName(c);
  }

  String? _partnerPic(Map c) {
    final p = c['partner'];
    if (p is Map) return p['profilePic'] as String?;
    return null;
  }

  String _status(Map c) => c['status'] as String? ?? 'Pending';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('chat_on'.tr),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatHistory.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64.sp, color: Colors.grey),
                      SizedBox(height: 16.h),
                      Text('no_chat_history'.tr,
                          style: AppTextStyles.bodyLarge),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    setState(() => isLoading = true);
                    await _loadHistory();
                  },
                  child: ListView.separated(
                    padding: EdgeInsets.all(16.w),
                    itemCount: chatHistory.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 12.h),
                    itemBuilder: (context, index) {
                      final chat = chatHistory[index];
                      final name = _partnerName(chat);
                      final pic = _partnerPic(chat);
                      final status = _status(chat);

                      return InkWell(
                        onTap: () {
                          Get.toNamed(
                            AppRoutes.chat,
                            arguments: {
                              'consultationId': chat['_id'],
                              'partner': chat['partner'],
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 24.r,
                                backgroundColor: AppColors.primary,
                                backgroundImage: pic != null && pic.isNotEmpty
                                    ? NetworkImage(pic)
                                    : null,
                                child: pic == null || pic.isEmpty
                                    ? const Icon(Icons.person,
                                        color: Colors.white)
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${'consultation_fee'.tr}: $status',
                                      style: AppTextStyles.caption,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right,
                                  color: AppColors.textHint),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
