import 'package:get/get.dart';
import '../../../home/presentation/controllers/home_controller.dart';
import '../../../astrologers/presentation/controllers/astrologer_controller.dart';
import '../../../profile/presentation/controllers/profile_controller.dart';
import '../../../chat/presentation/controllers/chat_list_controller.dart';
import '../../../chat/presentation/controllers/chat_history_controller.dart';
import '../../../live/presentation/controllers/live_controller.dart';

class DashboardController extends GetxController {
  final RxInt currentIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize all child controllers
    Get.put(HomeController());
    Get.put(AstrologerController());
    Get.put(LiveController());
    Get.put(ProfileController());
    Get.put(ChatListController());
    Get.put(ChatHistoryController());
  }

  @override
  void onClose() {
    // Clean up controllers
    Get.delete<HomeController>();
    Get.delete<AstrologerController>();
    Get.delete<LiveController>();
    Get.delete<ProfileController>();
    Get.delete<ChatListController>();
    Get.delete<ChatHistoryController>();
    super.onClose();
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 3 && Get.isRegistered<ChatHistoryController>()) {
      Get.find<ChatHistoryController>().fetchChatHistory();
    }
  }
}
