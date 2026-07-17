import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/constants/api_constants.dart';
import '../controllers/shop_controller.dart';
import '../widgets/checkout_sheet.dart';

class ShopPage extends GetView<ShopController> {
  const ShopPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shopBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Astrology Shop', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history, color: Colors.black),
            onPressed: () => Get.toNamed('/shop-orders'),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: () async {
                  await controller.loadCategories();
                  await controller.loadProducts();
                },
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _buildCategoriesSection()),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                      sliver: _buildProductsGridSliver(),
                    ),
                    SliverToBoxAdapter(child: SizedBox(height: 80.h)),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          onChanged: (v) => controller.searchProducts(v),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
            prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 20.sp),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 12.h),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection() {
    return Container(
      height: 44.h,
      margin: EdgeInsets.only(top: 16.h),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.categories.length + 1,
        itemBuilder: (context, index) {
          final isAll = index == 0;
          final category = isAll ? null : controller.categories[index - 1];
          final categoryId = isAll ? 'All' : category['_id'];
          final categoryName = isAll ? 'ALL' : (category['name']?.toString().toUpperCase() ?? 'CATEGORY');

          final isSelected = controller.selectedCategoryId.value == categoryId;

          return GestureDetector(
            onTap: () => controller.selectCategory(categoryId),
            child: Container(
              margin: EdgeInsets.only(right: 12.w),
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.shopMaroon : Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                categoryName,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                  fontSize: 12.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsGridSliver() {
    if (controller.products.isEmpty && !controller.isLoading.value) {
      return SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.only(top: 100.h),
            child: Text('No products available', style: AppTextStyles.bodyLarge),
          ),
        ),
      );
    }

    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.w,
        mainAxisSpacing: 16.h,
        childAspectRatio: 0.65,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final product = controller.products[index];
          final String? imageUrl = (product['images'] != null && (product['images'] as List).isNotEmpty)
              ? product['images'][0]
              : null;
          
          final price = product['price'] ?? 0;
          final salePrice = product['sale_price'] ?? 0;
          final hasSale = salePrice > 0 && salePrice < price;

          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                        ),
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                child: Image.network(ApiConstants.resolveImage(imageUrl), fit: BoxFit.cover),
                              )
                            : Icon(Icons.shopping_bag_outlined, size: 40.sp, color: Colors.grey.shade300),
                      ),
                      Positioned(
                        top: 10.h,
                        left: 10.w,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)],
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.star, color: Colors.orange, size: 12.sp),
                              SizedBox(width: 2.w),
                              Text('0', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10.h,
                        right: 10.w,
                        child: Container(
                          padding: EdgeInsets.all(6.w),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(Icons.favorite_border, color: Colors.grey, size: 16.sp),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] as String? ?? 'Product',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '0 REVIEWS',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'PRICE',
                        style: TextStyle(fontSize: 9.sp, color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '₹${hasSale ? salePrice : price}',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showBuyNowSheet(context, product);
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                color: AppColors.shopMaroon,
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                'Buy Now',
                                style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                              ),
                            ),
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
        childCount: controller.products.length,
      ),
    );
  }

  void _showBuyNowSheet(BuildContext context, Map<String, dynamic> product) {
    Get.bottomSheet(
      CheckoutSheet(product: product),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}
