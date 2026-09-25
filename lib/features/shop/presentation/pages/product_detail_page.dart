import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../controllers/shop_controller.dart';

class ProductDetailPage extends GetView<ShopController> {
  const ProductDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> product = Get.arguments as Map<String, dynamic>;
    
    final price = product['price'] ?? 0;
    final salePrice = product['sale_price'] ?? 0;
    final hasSale = salePrice > 0 && salePrice < price;
    final List images = product['images'] ?? [];
    final String description = product['description'] ?? 'No description available.';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Details'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Get.toNamed('/cart'),
              ),
              Obx(() => controller.cart.isEmpty 
                ? const SizedBox.shrink()
                : Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${controller.cart.length}',
                        style: TextStyle(color: Colors.white, fontSize: 10.sp),
                      ),
                    ),
                  )),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (images.isNotEmpty)
              SizedBox(
                height: 300.h,
                child: PageView.builder(
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    );
                  },
                ),
              )
            else
              Container(
                width: double.infinity,
                height: 250.h,
                color: AppColors.primary.withValues(alpha: 0.05),
                child: Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 120.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] as String? ?? 'Product',
                    style: AppTextStyles.h3,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      if (hasSale)
                        Text(
                          '₹$price',
                          style: AppTextStyles.h4.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      if (hasSale) SizedBox(width: 12.w),
                      Text(
                        '₹${hasSale ? salePrice : price}',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: 20.sp),
                      SizedBox(width: 4.w),
                      Text(
                        '${product['rating'] ?? 4.5} (${product['reviews_count'] ?? 0} reviews)',
                        style: AppTextStyles.bodyMedium,
                      ),
                      const Spacer(),
                      if ((product['stock_quantity'] ?? 0) > 0)
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'In Stock',
                            style: TextStyle(color: Colors.green, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        )
                      else
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.red.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(color: Colors.red, fontSize: 12.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text('Description', style: AppTextStyles.h4),
                  SizedBox(height: 8.h),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  Text('Key Benefits', style: AppTextStyles.h4),
                  SizedBox(height: 8.h),
                  _buildBenefitItem('Attracts positive energy and prosperity.'),
                  _buildBenefitItem('Helps in mitigating negative planetary effects.'),
                  _buildBenefitItem('Authentic and certified product.'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        bottom: true,
        child: Container(
          padding: EdgeInsets.all(16.w),
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
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => controller.addToCart(product),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    side: BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Add to Cart',
                    style: AppTextStyles.buttonSmall.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    controller.addToCart(product);
                    Get.toNamed('/cart');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text('Buy Now', style: AppTextStyles.buttonSmall),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: AppTextStyles.bodyMedium)),
        ],
      ),
    );
  }
}
