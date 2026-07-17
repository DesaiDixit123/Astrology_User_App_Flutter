import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';

class ShopOrderDetailPage extends StatelessWidget {
  const ShopOrderDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> order = Get.arguments ?? {};
    final String orderId = order['order_id'] ?? 'ORD-XXXX';
    final String status = (order['status'] ?? 'placed').toString().toUpperCase();
    final List items = order['items'] ?? [];
    final double totalAmount = (order['total_amount'] ?? 0).toDouble();
    final DateTime date = DateTime.parse(order['createdAt'] ?? DateTime.now().toIso8601String());
    final Map<String, dynamic> shippingAddress = order['shipping_address'] ?? {};

    return Scaffold(
      backgroundColor: AppColors.shopBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Order Detail', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderHeader(orderId, status, date),
            SizedBox(height: 20.h),
            _buildSectionTitle('ITEMS ORDERED'),
            _buildItemsList(items),
            SizedBox(height: 20.h),
            _buildSectionTitle('PAYMENT DETAILS'),
            _buildPaymentDetails(totalAmount),
            SizedBox(height: 20.h),
            _buildSectionTitle('SHIPPING INFO'),
            _buildShippingInfo(shippingAddress),
            SizedBox(height: 20.h),
            _buildSectionTitle('PAYMENT METHOD'),
            _buildPaymentMethodInfo(order),
            SizedBox(height: 40.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
      child: Text(
        title,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade700, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildOrderHeader(String id, String status, DateTime date) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.shopMaroon,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: AppColors.shopMaroon.withValues(alpha: 0.2), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('ORDER #$id', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.sp)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8.r)),
                child: Text(status, style: TextStyle(color: Colors.white, fontSize: 10.sp, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            DateFormat('MMMM dd, yyyy').format(date),
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(List items) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade50),
        itemBuilder: (context, index) {
          final item = items[index];
          final product = item['product_id'] ?? {};
          final String imageUrl = (product['images'] != null && (product['images'] as List).isNotEmpty)
              ? product['images'][0]
              : '';

          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12.r)),
                  child: imageUrl.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(12.r), child: Image.network(ApiConstants.resolveImage(imageUrl), fit: BoxFit.cover))
                      : Icon(Icons.shopping_bag, color: Colors.grey.shade300),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['name'] ?? 'Product',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp, color: Colors.black87)),
                      SizedBox(height: 4.h),
                      Text('Quantity: ${item['quantity']}', style: TextStyle(color: Colors.grey, fontSize: 11.sp)),
                    ],
                  ),
                ),
                Text('₹${item['price']}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp, color: AppColors.shopMaroon)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPaymentDetails(double total) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          _buildDetailRow('Subtotal', '₹${total.toInt()}'),
          SizedBox(height: 12.h),
          _buildDetailRow('Shipping', 'FREE', valueColor: Colors.green),
          SizedBox(height: 12.h),
          const Divider(),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp)),
              Text('₹${total.toInt()}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.sp, color: AppColors.shopMaroon)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 13.sp)),
        Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: valueColor ?? Colors.black87)),
      ],
    );
  }

  Widget _buildShippingInfo(Map<String, dynamic> address) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on_outlined, color: AppColors.shopMaroon, size: 20.sp),
              SizedBox(width: 8.w),
              Text(address['name'] ?? 'User Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
            ],
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.only(left: 28.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(address['mobile']?.toString() ?? 'Mobile No.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp)),
                SizedBox(height: 4.h),
                Text(
                  address['address'] ?? 'Shipping Address Not Available',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodInfo(Map<String, dynamic> order) {
    final method = (order['payment_method'] ?? 'wallet').toString().toLowerCase();
    final status = (order['payment_status'] ?? 'pending').toString().toUpperCase();
    
    String label = 'Wallet Payment';
    IconData icon = Icons.account_balance_wallet_outlined;
    
    if (method == 'cash on delivery' || method == 'cod') {
      label = 'Cash on Delivery';
      icon = Icons.money_outlined;
    } else if (method == 'online') {
      label = 'Online Payment';
      icon = Icons.payment_outlined;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Row(
        children: [
          Icon(icon, color: AppColors.shopMaroon, size: 20.sp),
          SizedBox(width: 12.w),
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
          const Spacer(),
          Text(status, style: TextStyle(
            color: status == 'PAID' || status == 'SUCCESS' ? Colors.green : Colors.orange, 
            fontWeight: FontWeight.bold, 
            fontSize: 11.sp
          )),
        ],
      ),
    );
  }
}
