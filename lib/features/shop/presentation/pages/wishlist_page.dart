import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../controllers/shop_controller.dart';
import '../widgets/checkout_sheet.dart';
import '../../../../shared/widgets/app_network_image.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final ShopController controller = Get.find<ShopController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.loadWishlistProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.shopBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('my_wishlist'.tr, style: const TextStyle(color: Colors.black)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
            onPressed: () => Get.toNamed('/cart'),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isWishlistLoading.value && controller.wishlistProducts.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.wishlistProductIds.isEmpty || controller.wishlistProducts.isEmpty) {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90.w,
                    height: 90.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.favorite_border, size: 48.sp, color: Colors.red),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'wishlist_empty_title'.tr,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'wishlist_empty_desc'.tr,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600, height: 1.4),
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.shopMaroon,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 28.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                    ),
                    child: Text('explore_shop'.tr, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.loadWishlistProducts(),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: GridView.builder(
              itemCount: controller.wishlistProducts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 0.65,
              ),
              itemBuilder: (context, index) {
                final product = controller.wishlistProducts[index];
                final String? imageUrl = (product['images'] != null && (product['images'] as List).isNotEmpty)
                    ? product['images'][0]
                    : null;

                final price = product['price'] ?? 0;
                final salePrice = product['sale_price'] ?? 0;
                final hasSale = salePrice > 0 && salePrice < price;
                final productId = product['_id']?.toString() ?? '';

                return GestureDetector(
                  onTap: () => Get.toNamed('/product-detail', arguments: product),
                  child: Container(
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
                              SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: AppNetworkImage(
                                  url: imageUrl,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.cover,
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                                  fallbackIcon: Icons.shopping_bag_outlined,
                                ),
                              ),
                              Positioned(
                                top: 10.h,
                                right: 10.w,
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () => controller.toggleWishlist(productId, product['name']?.toString()),
                                  child: Container(
                                    padding: EdgeInsets.all(6.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.1),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.favorite,
                                      color: Colors.red,
                                      size: 16.sp,
                                    ),
                                  ),
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
                                    onTap: () => _showBuyNowSheet(context, product),
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
                  ),
                );
              },
            ),
          ),
        );
      }),
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
