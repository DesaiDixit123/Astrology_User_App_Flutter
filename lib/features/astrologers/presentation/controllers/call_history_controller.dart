import 'package:get/get.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_service.dart';

class CallHistoryController extends GetxController {
  final _api = ApiService.instance;

  final RxList<Map<String, dynamic>> sessions = <Map<String, dynamic>>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCallHistory();
  }

  Future<void> fetchCallHistory() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    final res = await _api.get(
      ApiConstants.orders,
      queryParameters: {
        'page': 1,
        'limit': 50,
      },
    );

    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      final docs = data is Map ? data['docs'] : null;
      if (docs is List) {
        sessions.value = docs
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      } else {
        sessions.clear();
      }
      return;
    }

    errorMessage.value = res == null
        ? 'Unable to fetch call history. Please try again.'
        : ApiService.getMessage(res);
  }
}
