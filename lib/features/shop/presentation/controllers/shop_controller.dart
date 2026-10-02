import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class ShopController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList categories = [].obs;
  final RxList products = [].obs;
  final RxList recommendations = [].obs;
  final RxList myOrdersList = [].obs;
  final RxString selectedCategoryId = 'All'.obs;
  final RxString searchQuery = ''.obs;
  
  // Wishlist management
  final RxSet<String> wishlistProductIds = <String>{}.obs;
  final RxList wishlistProducts = [].obs;
  final RxBool isWishlistLoading = false.obs;

  // Cart management
  final RxList cart = [].obs;
  final RxDouble cartTotal = 0.0.obs;

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
    loadCategories();
    loadProducts();
    loadRecommendations();
  }

  Future<void> loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList('shop_wishlist') ?? [];
      wishlistProductIds.assignAll(list);
    } catch (_) {}
  }

  Future<void> loadWishlistProducts() async {
    if (wishlistProductIds.isEmpty) {
      wishlistProducts.clear();
      return;
    }
    isWishlistLoading.value = true;
    final res = await _api.get(ApiConstants.shopProducts, queryParameters: {
      'ids': wishlistProductIds.join(','),
      'limit': 100,
    });
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map && data.containsKey('docs')) {
        wishlistProducts.value = List.from(data['docs']);
      } else {
        wishlistProducts.value = List.from(data ?? []);
      }
    }
    isWishlistLoading.value = false;
  }

  bool isWishlisted(String productId) {
    return wishlistProductIds.contains(productId);
  }

  Future<void> toggleWishlist(String productId, [String? productName]) async {
    if (productId.isEmpty) return;
    if (wishlistProductIds.contains(productId)) {
      wishlistProductIds.remove(productId);
      wishlistProducts.removeWhere((item) => item['_id'] == productId);
      SnackbarUtil.info('${productName ?? 'Product'} removed from wishlist');
    } else {
      wishlistProductIds.add(productId);
      final item = products.firstWhereOrNull((p) => p['_id'] == productId);
      if (item != null && !wishlistProducts.any((p) => p['_id'] == productId)) {
        wishlistProducts.add(item);
      }
      SnackbarUtil.success('${productName ?? 'Product'} added to wishlist');
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('shop_wishlist', wishlistProductIds.toList());
    } catch (_) {}
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    final res = await _api.get(ApiConstants.shopCategories);
    if (ApiService.isSuccess(res)) {
      categories.value = List.from(ApiService.getData(res) ?? []);
    }
    isLoading.value = false;
  }

  Future<void> loadProducts({String? categoryId, String? query, bool refresh = true}) async {
    isLoading.value = true;
    final catId = categoryId ?? selectedCategoryId.value;
    final res = await _api.get(ApiConstants.shopProducts, queryParameters: {
      if (catId.isNotEmpty && catId != 'All') 'categoryId': catId,
      if (query != null && query.isNotEmpty) 'search': query,
      'limit': 50,
    });
    
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map && data.containsKey('docs')) {
        products.value = List.from(data['docs']);
      } else {
        products.value = List.from(data ?? []);
      }
    }
    isLoading.value = false;
  }

  Future<void> loadRecommendations() async {
    final res = await _api.get(ApiConstants.shopRecommendations);
    if (ApiService.isSuccess(res)) {
      recommendations.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  void selectCategory(String id) {
    selectedCategoryId.value = id;
    loadProducts(categoryId: id, query: searchQuery.value);
  }

  void searchProducts(String query) {
    searchQuery.value = query;
    loadProducts(categoryId: selectedCategoryId.value, query: query);
  }

  // Cart Methods
  void addToCart(Map<String, dynamic> product) {
    final index = cart.indexWhere((item) => item['_id'] == product['_id']);
    if (index != -1) {
      cart[index]['quantity'] = (cart[index]['quantity'] ?? 1) + 1;
      cart.refresh();
    } else {
      final newItem = Map<String, dynamic>.from(product);
      newItem['quantity'] = 1;
      cart.add(newItem);
    }
    calculateTotal();
    SnackbarUtil.success('${product['name']} added to cart');
  }

  void removeFromCart(String productId) {
    cart.removeWhere((item) => item['_id'] == productId);
    calculateTotal();
  }

  void updateQuantity(String productId, int delta) {
    final index = cart.indexWhere((item) => item['_id'] == productId);
    if (index != -1) {
      final newQty = (cart[index]['quantity'] ?? 1) + delta;
      if (newQty > 0) {
        cart[index]['quantity'] = newQty;
        cart.refresh();
      } else {
        cart.removeAt(index);
      }
      calculateTotal();
    }
  }

  void calculateTotal() {
    double total = 0;
    for (var item in cart) {
      final price = (item['sale_price'] != null && item['sale_price'] > 0)
          ? item['sale_price']
          : item['price'];
      total += (price ?? 0) * (item['quantity'] ?? 1);
    }
    cartTotal.value = total;
  }

  Future<Map<String, dynamic>?> placeOrder(Map<String, dynamic> shippingAddress, {String paymentMethod = 'wallet'}) async {
    if (cart.isEmpty) return null;

    isLoading.value = true;
    final orderItems = cart.map((item) => {
      'product_id': item['_id'],
      'quantity': item['quantity'],
    }).toList();

    final res = await _api.post(ApiConstants.placeOrder, data: {
      'items': orderItems,
      'shipping_address': shippingAddress,
      'payment_method': paymentMethod,
    });

    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (paymentMethod != 'online') {
        cart.clear();
        calculateTotal();
        Get.offNamed('/shop-orders');
        SnackbarUtil.success('Order placed successfully!');
      }
      return data;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return null;
    }
  }

  Future<bool> verifyOrder(String orderId, String paymentId, String razorpayOrderId, String signature) async {
    isLoading.value = true;
    final res = await _api.post('${ApiConstants.placeOrder}/verify', data: {
      'order_id': orderId,
      'razorpay_payment_id': paymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': signature,
    });
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      cart.clear();
      calculateTotal();
      Get.offNamed('/shop-orders');
      SnackbarUtil.success('Payment successful & Order placed!');
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return false;
    }
  }

  Future<void> loadMyOrders() async {
    isLoading.value = true;
    final res = await _api.post(ApiConstants.myOrders, data: {'page': 1, 'limit': 100});
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map && data.containsKey('docs')) {
        myOrdersList.value = List.from(data['docs']);
      } else {
        myOrdersList.value = List.from(data ?? []);
      }
    }
    isLoading.value = false;
  }
}
