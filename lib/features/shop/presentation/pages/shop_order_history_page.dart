import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/shop_controller.dart';

class ShopOrderHistoryPage extends StatefulWidget {
  const ShopOrderHistoryPage({super.key});

  @override
  State<ShopOrderHistoryPage> createState() => _ShopOrderHistoryPageState();
}

class _ShopOrderHistoryPageState extends State<ShopOrderHistoryPage> {
  final controller = Get.find<ShopController>();

  @override
  void initState() {
    super.initState();
    // Load orders when page opens, after the frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadMyOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shopBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Orders History', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.myOrdersList.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.myOrdersList.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_bag_outlined, size: 80.sp, color: Colors.grey.shade300),
                SizedBox(height: 16.h),
                Text('No orders found', style: TextStyle(color: Colors.grey, fontSize: 16.sp)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadMyOrders(),
          child: Column(
            children: [
              _buildTableHeader(),
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  itemCount: controller.myOrdersList.length,
                  itemBuilder: (context, index) {
                    final order = controller.myOrdersList[index];
                    return _buildOrderRow(order);
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      margin: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: _headerCell('Order ID')),
          Expanded(flex: 4, child: _headerCell('Product Name')),
          Expanded(flex: 2, child: _headerCell('Total')),
          Expanded(flex: 3, child: _headerCell('Status')),
          Expanded(flex: 2, child: _headerCell('Action', align: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _headerCell(String text, {TextAlign align = TextAlign.start}) {
    return Text(
      text,
      textAlign: align,
      style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
    );
  }

  Widget _buildOrderRow(Map<String, dynamic> order) {
    final String orderId = order['order_id'] ?? 'ORD-XXXX';
    final String status = order['status'] ?? 'placed';
    final double amount = (order['total_amount'] ?? 0).toDouble();
    final List items = order['items'] ?? [];
    final String productName = items.isNotEmpty ? (items[0]['product_id']?['name'] ?? 'Product') : 'N/A';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade50)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              orderId,
              style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.blue.shade700),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              productName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '₹${amount.toInt()}',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 3,
            child: _buildStatusBadge(status),
          ),
          Expanded(
            flex: 2,
            child: IconButton(
              icon: Icon(Icons.visibility_outlined, size: 18.sp, color: Colors.grey),
              onPressed: () {
                // Navigate to Order Details
                Get.toNamed('/shop-order-detail', arguments: order);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    status = status.toLowerCase();
    Color bgColor = AppColors.shopPillYellow;
    Color textColor = AppColors.shopTextYellow;
    String label = status.toUpperCase();

    if (status == 'placed' || status == 'success' || status == 'delivered') {
      bgColor = AppColors.shopPillGreen;
      textColor = AppColors.shopTextGreen;
    } else if (status == 'pending') {
      bgColor = AppColors.shopPillYellow;
      textColor = AppColors.shopTextYellow;
    } else if (status == 'shipped') {
      bgColor = AppColors.shopPillBlue;
      textColor = AppColors.shopTextBlue;
    } else if (status == 'cancelled') {
      bgColor = Colors.red.shade50;
      textColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12.r)),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(color: textColor, fontSize: 9.sp, fontWeight: FontWeight.bold),
      ),
    );
  }
}

