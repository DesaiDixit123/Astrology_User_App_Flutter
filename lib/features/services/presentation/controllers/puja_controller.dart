import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../data/models/puja_model.dart';

class PujaController extends GetxController {
  final RxList<PujaCategory> categories = <PujaCategory>[].obs;
  final RxList<Puja> pujas = <Puja>[].obs;
  final Rx<Puja?> pujaDetail = Rx<Puja?>(null);
  final RxList faqs = [].obs;
  final RxBool isLoading = false.obs;
  final RxList<PujaSubCategory> subCategories = <PujaSubCategory>[].obs;
  final RxList<Puja> searchResults = <Puja>[].obs;
  final RxList<PujaOrder> myOrders = <PujaOrder>[].obs;
  final Rx<PujaOrder?> orderDetail = Rx<PujaOrder?>(null);
  final RxList<PujaPackage> packages = <PujaPackage>[].obs;

  @override
  void onInit() {
    super.onInit();
    getPujaCategories();
  }

  Future<void> getPujaCategories() async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.get(ApiConstants.pujaCategories);
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        categories.assignAll(data.map((e) => PujaCategory.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Puja categories');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getSubCategories(String categoryId) async {
    try {
      isLoading.value = true;
      subCategories.clear();
      final response = await ApiService.instance.get('${ApiConstants.pujaSubcategories}/$categoryId');
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        subCategories.assignAll(data.map((e) => PujaSubCategory.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load subcategories');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPujaListByCategoryId(String categoryId) async {
    try {
      isLoading.value = true;
      pujas.clear();
      final response = await ApiService.instance.get('${ApiConstants.pujaList}/$categoryId');
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        pujas.assignAll(data.map((e) => Puja.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Pujas');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPujaListBySubCategoryId(String subCategoryId) async {
    try {
      isLoading.value = true;
      pujas.clear();
      final response = await ApiService.instance.get('${ApiConstants.pujaSublist}/$subCategoryId');
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        pujas.assignAll(data.map((e) => Puja.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Pujas by subcategory');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPujaDetails(String pujaId) async {
    try {
      isLoading.value = true;
      pujaDetail.value = null;
      final response = await ApiService.instance.get('${ApiConstants.pujaDetails}/$pujaId');
      if (ApiService.isSuccess(response)) {
        final Map<String, dynamic> data = ApiService.getData(response);
        pujaDetail.value = Puja.fromJson(data);
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Puja details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchPujas(String query) async {
    try {
      isLoading.value = true;
      searchResults.clear();
      final response = await ApiService.instance.get('${ApiConstants.pujaSearch}?search=$query');
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        searchResults.assignAll(data.map((e) => Puja.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Search failed');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPujaFaqs() async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.get(ApiConstants.pujaFaqs);
      if (ApiService.isSuccess(response)) {
        faqs.assignAll(ApiService.getData(response) ?? []);
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Puja FAQs');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getPujaPackages(String pujaId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.get('${ApiConstants.pujaPackages}/$pujaId');
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        packages.assignAll(data.map((e) => PujaPackage.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load Puja packages');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> bookPuja(PujaOrderRequest request) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.post(ApiConstants.bookPuja, data: request.toJson());
      if (ApiService.isSuccess(response)) {
        SnackbarUtil.success('Puja booked successfully');
        return true;
      } else {
        SnackbarUtil.error(ApiService.getMessage(response));
        return false;
      }
    } catch (e) {
      SnackbarUtil.error('Failed to book Puja');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>?> createPujaPayment(String packageId) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.post(ApiConstants.createPujaPayment, data: {'packageId': packageId});
      if (ApiService.isSuccess(response)) {
        final data = ApiService.getData(response);
        return data['razorpay_order'];
      }
      return null;
    } catch (e) {
      SnackbarUtil.error('Failed to initialize payment');
      return null;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> verifyPujaOrder(String orderId, String paymentId, String razorpayOrderId, String signature) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.post(ApiConstants.verifyPujaOrder, data: {
        'order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_order_id': razorpayOrderId,
        'razorpay_signature': signature,
      });
      return ApiService.isSuccess(response);
    } catch (e) {
      SnackbarUtil.error('Payment verification failed');
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyPujaOrders() async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.post(ApiConstants.myPujaOrders, data: {});
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response)['docs'] ?? [];
        myOrders.assignAll(data.map((e) => PujaOrder.fromJson(e)).toList());
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load my puja orders');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getMyPujaOrderDetail(String id) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.get('${ApiConstants.pujaOrderDetail}/$id');
      if (ApiService.isSuccess(response)) {
        orderDetail.value = PujaOrder.fromJson(ApiService.getData(response));
      }
    } catch (e) {
      SnackbarUtil.error('Failed to load order details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> cancelPuja(String orderId, String reason) async {
    try {
      isLoading.value = true;
      final response = await ApiService.instance.post(ApiConstants.cancelPujaOrder, data: {
        'orderId': orderId,
        'reason': reason,
      });
      if (ApiService.isSuccess(response)) {
        SnackbarUtil.success('Puja order cancelled');
        getMyPujaOrders(); // Refresh the list
        return true;
      } else {
        SnackbarUtil.error(ApiService.getMessage(response));
        return false;
      }
    } catch (e) {
      SnackbarUtil.error('Failed to cancel Puja order');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}



