import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/shop_controller.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../widgets/checkout_sheet.dart';

class CartPage extends GetView<ShopController> {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.cart.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined, size: 80.sp, color: AppColors.textSecondary.withValues(alpha: 0.3)),
                SizedBox(height: 16.h),
                Text('Your cart is empty', style: AppTextStyles.bodyLarge),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: const Text('Go Shopping'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(16.w),
                itemCount: controller.cart.length,
                itemBuilder: (context, index) {
                  final item = controller.cart[index];
                  final String? imageUrl = (item['images'] != null && (item['images'] as List).isNotEmpty)
                      ? item['images'][0]
                      : null;
                  
                  final price = (item['sale_price'] != null && item['sale_price'] > 0)
                      ? item['sale_price']
                      : item['price'];

                  return Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.shadow.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 80.w,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: imageUrl != null 
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12.r),
                                  child: Image.network(ApiConstants.resolveImage(imageUrl), fit: BoxFit.cover),
                                )
                              : Icon(Icons.shopping_bag_outlined, size: 40.sp, color: AppColors.primary),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'] as String? ?? 'Product',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                '₹$price',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Row(
                                children: [
                                  _buildQtyBtn(Icons.remove, () => controller.updateQuantity(item['_id'], -1)),
                                  SizedBox(width: 12.w),
                                  Text(
                                    '${item['quantity']}',
                                    style: AppTextStyles.bodyLarge,
                                  ),
                                  SizedBox(width: 12.w),
                                  _buildQtyBtn(Icons.add, () => controller.updateQuantity(item['_id'], 1)),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => controller.removeFromCart(item['_id']),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            _buildBottomSection(),
          ],
        );
      }),
    );
  }

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, size: 16.sp),
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Payable', style: AppTextStyles.h4),
              Obx(() => Text(
                '₹${controller.cartTotal.value.toStringAsFixed(2)}',
                style: AppTextStyles.h3.copyWith(color: AppColors.primary),
              )),
            ],
          ),
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            child: CustomButton(
              text: 'Checkout',
              onPressed: () => Get.bottomSheet(
                const CheckoutSheet(product: null),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
              backgroundColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

}
