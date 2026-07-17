import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';

class ChatHistoryDetailController extends GetxController {
  final _api = ApiService.instance;
  final RxList messages = [].obs;
  final RxBool isLoading = false.obs;
  final RxMap partner = {}.obs;
  final RxString sessionId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map?;
    if (args != null) {
      partner.value = args['partner'] ?? {};
      sessionId.value = args['sessionId'] ?? '';
      if (sessionId.value.isNotEmpty) {
        fetchMessages();
      }
    }
  }

  Future<void> fetchMessages() async {
    isLoading.value = true;
    final res = await _api.get('/customer/chat/messages/${sessionId.value}');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      messages.value = List.from(ApiService.getData(res) ?? []);
    }
  }
}
