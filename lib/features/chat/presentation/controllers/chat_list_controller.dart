import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';

class ChatListController extends GetxController {
  final _api = ApiService.instance;
  final RxList sessions = [].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchChatSessions();
  }

  Future<void> fetchChatSessions() async {
    if (isLoading.value) return;
    isLoading.value = true;
    errorMessage.value = '';
    final res = await _api.get('/customer/chat/sessions');
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      sessions.value = List.from(ApiService.getData(res) ?? []);
      errorMessage.value = '';
    } else {
      errorMessage.value =
          res == null ? 'Unable to fetch chats. Please try again.' : ApiService.getMessage(res);
    }
  }
}
