import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import '../controllers/shop_controller.dart';

import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../../core/constants/app_constants.dart';

class CheckoutSheet extends StatefulWidget {
  final Map<String, dynamic>? product; // Null means Checkout from Cart
  const CheckoutSheet({super.key, this.product});

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  String selectedPaymentMethod = 'wallet';
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    // Pre-fill from Profile if available
    try {
      final profile = Get.find<GetxController>(tag: 'ProfileController') as dynamic;
      nameController.text = profile.userData['name'] ?? '';
      mobileController.text = profile.userData['mobile']?.toString() ?? '';
    } catch (_) {}
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final controller = Get.find<ShopController>();
    if (response.paymentId != null && response.orderId != null && response.signature != null) {
      // Find the order ID from our backend order data
      // In placeOrder response, we get { order: newOrder, razorpay_order: rpOrder }
      // The order_id needed for verify is newOrder._id
      
      // We need to store high level order data during the flow
      if (_lastCreatedOrderId != null) {
        await controller.verifyOrder(
          _lastCreatedOrderId!, 
          response.paymentId!, 
          response.orderId!, 
          response.signature!
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar('Payment Error', response.message ?? 'Unknown error');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', response.walletName ?? '');
  }

  String? _lastCreatedOrderId;

  void _startRazorpayPayment(Map<String, dynamic> data) {
    final razorpayOrder = data['razorpay_order'];
    final order = data['order'];
    _lastCreatedOrderId = order['_id'];

    final options = {
      'key': AppConstants.razorpayKeyId,
      'amount': razorpayOrder['amount'],
      'name': 'Vedikvani Wellness Shop',
      'order_id': razorpayOrder['id'],
      'description': 'Order Payment',
      'prefill': {
        'contact': mobileController.text,
        'name': nameController.text,
      },
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar('Error', 'Could not open payment gateway');
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ShopController>();
    final double price = widget.product != null 
        ? ((widget.product!['sale_price'] ?? 0) > 0 ? (widget.product!['sale_price'] ?? 0).toDouble() : (widget.product!['price'] ?? 0).toDouble())
        : controller.cartTotal.value;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle('SHIPPING DETAILS', color: const Color(0xFFE8F5E9)),
                    SizedBox(height: 16.h),
                    _buildLabel('FULL NAME'),
                    CustomTextField(controller: nameController, hintText: 'Enter full name'),
                    SizedBox(height: 12.h),
                    _buildLabel('MOBILE NUMBER'),
                    CustomTextField(controller: mobileController, hintText: 'Enter mobile number', keyboardType: TextInputType.phone),
                    SizedBox(height: 12.h),
                    _buildLabel('SHIPPING ADDRESS'),
                    CustomTextField(
                      controller: addressController,
                      hintText: 'Enter complete address (House no, Street, Landmark, City, State, Pincode)',
                      maxLines: 3,
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('ORDER SUMMARY', color: const Color(0xFFE8F5E9)),
                    SizedBox(height: 16.h),
                    _buildOrderSummarySection(price),
                    const Divider(),
                    _buildPriceRow('Order Value:', '₹$price'),
                    _buildPriceRow('Shipping:', 'FREE', valueColor: Colors.green),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('NET PAYABLE:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                        Text('₹$price', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('PAYMENT METHOD', color: Colors.white, showBorder: true),
                    SizedBox(height: 12.h),
                    _buildPaymentMethods(),
                    SizedBox(height: 24.h),
                    CustomButton(
                      text: 'FINALIZE ORDER',
                      onPressed: _handleFinalizeOrder,
                      backgroundColor: const Color(0xFF34495E),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          Positioned(
            right: 0,
            child: GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(color: Colors.grey.shade100, shape: BoxShape.circle),
                child: Icon(Icons.close, size: 18.sp, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {required Color color, bool showBorder = false}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4.r),
        border: showBorder ? Border.all(color: Colors.grey.shade200) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        title,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87, letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 4.w),
      child: Text(text, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: Colors.grey)),
    );
  }

  Widget _buildOrderSummarySection(double total) {
    final controller = Get.find<ShopController>();
    if (widget.product != null) {
      return _buildOrderSummaryRow(widget.product!, total);
    } else {
      return Column(
        children: controller.cart.map((item) {
          final itemPrice = (item['sale_price'] ?? 0) > 0 ? item['sale_price'] : item['price'];
          return Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: _buildOrderSummaryRow(item, itemPrice.toDouble()),
          );
        }).toList(),
      );
    }
  }

  Widget _buildOrderSummaryRow(Map<String, dynamic> product, double price) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: product['images'] != null && (product['images'] as List).isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(ApiConstants.resolveImage(product['images'][0]), fit: BoxFit.cover),
                  )
                : Icon(Icons.shopping_bag, color: Colors.grey.shade300),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
                Text('₹$price ${product['quantity'] != null ? 'x${product['quantity']}' : ''}', 
                     style: TextStyle(color: AppColors.shopMaroon, fontWeight: FontWeight.bold, fontSize: 12.sp)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey, fontSize: 13.sp)),
          Text(value, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13.sp, color: valueColor)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    final walletController = Get.find<WalletController>();
    return Column(
      children: [
        _buildPaymentOption(
          'Wallet',
          '₹${walletController.walletBalance.value.toStringAsFixed(2)} AVAIL.',
          Icons.account_balance_wallet_outlined,
          'wallet',
        ),
        SizedBox(height: 8.h),
        _buildPaymentOption('Razorpay', '', Icons.payment_outlined, 'online'),
        SizedBox(height: 8.h),
        _buildPaymentOption('Cash on Delivery', '', Icons.money_outlined, 'cod'),
      ],
    );
  }

  Widget _buildPaymentOption(String title, String subtitle, IconData icon, String key) {
    final isSelected = selectedPaymentMethod == key;
    return GestureDetector(
      onTap: () => setState(() => selectedPaymentMethod = key),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: isSelected ? AppColors.shopMaroon : Colors.grey.shade200),
          color: isSelected ? AppColors.shopMaroon.withValues(alpha: 0.02) : Colors.white,
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, 
                 color: isSelected ? AppColors.shopMaroon : Colors.grey, size: 20.sp),
            SizedBox(width: 12.w),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp)),
            const Spacer(),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 11.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleFinalizeOrder() async {
    if (nameController.text.isEmpty || mobileController.text.isEmpty || addressController.text.isEmpty) {
      Get.snackbar('Error', 'Please fill all details');
      return;
    }

    final shippingAddress = {
      'name': nameController.text.trim(),
      'mobile': mobileController.text.trim(),
      'address': addressController.text.trim(),
    };

    final controller = Get.find<ShopController>();
    final walletController = Get.find<WalletController>();

    final double price = widget.product != null 
        ? ((widget.product!['sale_price'] ?? 0) > 0 ? (widget.product!['sale_price'] ?? 0).toDouble() : (widget.product!['price'] ?? 0).toDouble())
        : controller.cartTotal.value;

    if (selectedPaymentMethod == 'wallet' && walletController.walletBalance.value < price) {
      Get.snackbar('Insufficient Balance', 'Please recharge your wallet or choose another payment method.');
      return;
    }

    if (widget.product != null) {
      // Direct Buy Now
      controller.cart.clear();
      controller.addToCart(widget.product!);
    }
    
    final orderData = await controller.placeOrder(shippingAddress, paymentMethod: selectedPaymentMethod);
    if (orderData != null) {
      if (selectedPaymentMethod == 'online') {
        _startRazorpayPayment(orderData);
      } else {
        Get.back();
      }
    }
  }
}
