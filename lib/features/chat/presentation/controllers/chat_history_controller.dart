import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';

class ChatHistoryController extends GetxController {
  final _api = ApiService.instance;
  final RxList historySessions = [].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatHistory();
  }

  Future<void> fetchChatHistory() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    
    // Fetch all sessions and filter for 'completed' status
    final res = await _api.get('/customer/chat/sessions');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      final List allSessions = List.from(data is Map ? (data['docs'] ?? []) : (data ?? []));
      // Filter for history (completed sessions)
      historySessions.value = allSessions.where((s) => s['status'] == 'completed').toList();
      errorMessage.value = '';
    } else {
      errorMessage.value =
          res == null ? 'Unable to fetch chat history. Please try again.' : ApiService.getMessage(res);
    }
  }
}
