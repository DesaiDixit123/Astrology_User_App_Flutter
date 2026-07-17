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
          'name': 'Acharya Ravi',
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
    final p = c['partner'];
    if (p is Map) return p['name'] as String? ?? 'Astrologer';
    return 'Astrologer';
  }

  String? _partnerPic(Map c) {
    final p = c['partner'];
    if (p is Map) return p['profilePic'] as String?;
    return null;
  }

  String _status(Map c) => c['status'] as String? ?? 'Pending';

  String _formatDate(dynamic raw) {
    if (raw == null) return '';
    try {
      final dt = DateTime.parse(raw.toString()).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      return '${dt.day}/${dt.month}/${dt.year}';
    } catch (_) {
      return '';
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'Pending':
        return Colors.orange;
      case 'Accepted':
      case 'InProgress':
        return Colors.green;
      case 'Completed':
        return Colors.grey;
      case 'Rejected':
      case 'Cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chats'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : chatHistory.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64.sp,
                    color: Colors.grey.shade300,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'No chat history yet',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton.icon(
                    onPressed: () => Get.toNamed(AppRoutes.astrologerList),
                    icon: const Icon(Icons.search),
                    label: const Text('Find an Astrologer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => isLoading = true);
                await _loadHistory();
              },
              child: ListView.separated(
                itemCount: chatHistory.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final chat = chatHistory[index];
                  return _buildChatTile(chat);
                },
              ),
            ),
    );
  }

  Widget _buildChatTile(Map chat) {
    final name = _partnerName(chat);
    final pic = _partnerPic(chat);
    final status = _status(chat);
    final time = _formatDate(chat['updatedAt'] ?? chat['createdAt']);
    final isActive =
        status == 'Pending' || status == 'Accepted' || status == 'InProgress';

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      leading: CircleAvatar(
        radius: 24.r,
        backgroundColor: AppColors.primary,
        backgroundImage: pic != null && pic.isNotEmpty
            ? NetworkImage(pic)
            : null,
        child: (pic == null || pic.isEmpty)
            ? Text(
                name[0].toUpperCase(),
                style: AppTextStyles.bodyLarge.copyWith(color: Colors.white),
              )
            : null,
      ),
      title: Text(
        name,
        style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            margin: EdgeInsets.only(right: 6.w),
            decoration: BoxDecoration(
              color: _statusColor(status),
              shape: BoxShape.circle,
            ),
          ),
          Text(status, style: AppTextStyles.caption),
        ],
      ),
      trailing: Text(time, style: AppTextStyles.caption),
      onTap: () {
        if (isActive) {
          Get.toNamed(
            AppRoutes.chat,
            arguments: {
              ...Map.from(chat['partner'] is Map ? chat['partner'] : {}),
              'consultationId': chat['_id'],
            },
          );
        } else {
          final partner = chat['partner'];
          if (partner is Map) {
            Get.toNamed(AppRoutes.chat, arguments: Map.from(partner));
          }
        }
      },
    );
  }
}
