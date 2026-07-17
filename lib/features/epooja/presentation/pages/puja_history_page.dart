import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../services/presentation/controllers/puja_controller.dart';
import '../../../services/data/models/puja_model.dart';
import '../../../../config/routes/app_routes.dart';

class PujaHistoryPage extends StatefulWidget {
  const PujaHistoryPage({super.key});

  @override
  State<PujaHistoryPage> createState() => _PujaHistoryPageState();
}

class _PujaHistoryPageState extends State<PujaHistoryPage> {
  final controller = Get.find<PujaController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getMyPujaOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: Text('My Puja History', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.myOrders.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.myOrders.isEmpty) {
                return _buildEmptyState();
              }

              return RefreshIndicator(
                onRefresh: () => controller.getMyPujaOrders(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  itemCount: controller.myOrders.length,
                  itemBuilder: (context, index) {
                    final order = controller.myOrders[index];
                    return _buildOrderCard(order);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 20.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('MY ', style: AppTextStyles.h1.copyWith(color: const Color(0xFF1E2633), letterSpacing: 1)),
              Text('PUJA', style: AppTextStyles.h1.copyWith(color: const Color(0xFF451A03), fontStyle: FontStyle.italic, letterSpacing: 1)),
            ],
          ),
          SizedBox(height: 8.h),
          Container(width: 40.w, height: 3.h, color: const Color(0xFF451A03)),
          SizedBox(height: 15.h),
          Text(
            'Track all your booked pujas. View broadcast links, package details, and puja schedules in one place.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.temple_hindu, size: 80.sp, color: const Color(0xFFE2E8F0)),
          SizedBox(height: 20.h),
          Text('No Puja History Found', style: AppTextStyles.h4.copyWith(color: const Color(0xFF1E2633))),
          SizedBox(height: 10.h),
          Text('You haven\'t booked any pujas yet.', style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF94A3B8))),
        ],
      ),
    );
  }

  Widget _buildOrderCard(PujaOrder order) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('#${order.orderId}', style: AppTextStyles.bodyMedium.copyWith(color: const Color(0xFF92400E), fontWeight: FontWeight.w900)),
              _statusBadge(order.status),
            ],
          ),
          const Divider(height: 30, thickness: 1, color: Color(0xFFF1F5F9)),
          Row(
            children: [
              _buildAvatar(order.astrologerId),
              SizedBox(width: 15.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Puja Scheduled', style: AppTextStyles.caption.copyWith(color: const Color(0xFF94A3B8))),
                    SizedBox(height: 4.h),
                    Text(order.bookingDate, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF1E2633))),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _modeBadge(order.mode),
                  SizedBox(height: 8.h),
                  Text('₹${order.amount}', style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF1E2633))),
                ],
              ),
            ],
          ),
          const Divider(height: 30, thickness: 1, color: Color(0xFFF1F5F9)),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              _actionButton(Icons.visibility_outlined, const Color(0xFF64748B), () => _viewDetails(order)),
              if (order.status.toUpperCase() == 'PLACED') ...[
                SizedBox(width: 15.w),
                _actionButton(Icons.cancel_outlined, const Color(0xFFEF4444), () => _confirmCancel(order)),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(String id) {
    return Container(
      width: 45.w,
      height: 45.w,
      decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFF8FAFC)),
      child: Icon(Icons.person, color: const Color(0xFFCBD5E1), size: 28.sp),
    );
  }

  Widget _statusBadge(String status) {
    Color color = const Color(0xFF3B82F6);
    if (status.toUpperCase() == 'CANCELLED') color = const Color(0xFFEF4444);
    if (status.toUpperCase() == 'COMPLETED') color = const Color(0xFF10B981);
    if (status.toUpperCase() == 'REFUNDED') color = const Color(0xFFF59E0B);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8.r)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10.sp, fontWeight: FontWeight.w900, letterSpacing: 0.5),
      ),
    );
  }

  Widget _modeBadge(String mode) {
    bool isOnline = mode.toLowerCase() == 'online';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(color: isOnline ? const Color(0xFFF5F3FF) : const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isOnline ? Icons.videocam_outlined : Icons.location_on_outlined, size: 12.sp, color: isOnline ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B)),
          SizedBox(width: 4.w),
          Text(mode.toUpperCase(), style: TextStyle(color: isOnline ? const Color(0xFF8B5CF6) : const Color(0xFFF59E0B), fontSize: 10.sp, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color.withOpacity(0.2))),
        child: Icon(icon, color: color, size: 18.sp),
      ),
    );
  }

  void _viewDetails(PujaOrder order) {
    Get.toNamed(AppRoutes.pujaHistoryDetail, arguments: order);
  }

  void _confirmCancel(PujaOrder order) {
    final reasonController = TextEditingController();
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
        title: Text('Cancel Booking?', style: AppTextStyles.h4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this puja booking?', style: AppTextStyles.bodyMedium),
            SizedBox(height: 20.h),
            Text('Reason for cancellation', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.bold)),
            SizedBox(height: 10.h),
            TextField(
              controller: reasonController,
              decoration: InputDecoration(
                hintText: 'Enter reason here...',
                hintStyle: AppTextStyles.bodySmall.copyWith(color: Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                contentPadding: EdgeInsets.all(12.w),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('No', style: TextStyle(color: Colors.grey[600]))),
          TextButton(
            onPressed: () async {
              if (reasonController.text.trim().isEmpty) {
                Get.snackbar('Error', 'Please enter a reason for cancellation', 
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white);
                return;
              }
              Get.back();
              final success = await controller.cancelPuja(order.id, reasonController.text.trim());
              if (success) {
                // controller refreshes list on success
              }
            },
            child: const Text('Yes, Cancel', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Simple Detail Page Placeholder
class PujaHistoryDetailPage extends StatelessWidget {
  final PujaOrder order;
  const PujaHistoryDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: Text('Booking Details', style: AppTextStyles.h4),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Get.back()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(25.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             _buildInfoSection('ORDER INFORMATION', [
               _infoRow('Status', order.status.toUpperCase()),
               _infoRow('Order Date', DateFormat('dd MMM yyyy').format(order.createdAt)),
               _infoRow('Booking Date', order.bookingDate),
               _infoRow('Puja Mode', order.mode.toUpperCase()),
             ]),
             SizedBox(height: 25.h),
             if (order.shippingDetails != null)
               _buildInfoSection('SHIPPING DETAILS', [
                 _infoRow('Recipient', order.shippingDetails!['name'] ?? 'N/A'),
                 _infoRow('Phone', order.shippingDetails!['phone_no'] ?? 'N/A'),
                 _infoRow('Address', '${order.shippingDetails!['flat_house_no']}, ${order.shippingDetails!['locality']}'),
                 _infoRow('City', '${order.shippingDetails!['city']}, ${order.shippingDetails!['state']}'),
                 _infoRow('Pincode', order.shippingDetails!['pincode'] ?? 'N/A'),
               ]),
             SizedBox(height: 25.h),
             _buildInfoSection('PAYMENT INFORMATION', [
               _infoRow('Amount Paid', '₹${order.amount}'),
               _infoRow('Payment Method', order.paymentMethod.toUpperCase()),
               _infoRow('Payment Status', order.paymentStatus.toUpperCase()),
             ]),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20.r), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF64748B), fontWeight: FontWeight.bold, letterSpacing: 0.5)),
          SizedBox(height: 15.h),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF94A3B8))),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: const Color(0xFF1E2633))),
        ],
      ),
    );
  }
}
