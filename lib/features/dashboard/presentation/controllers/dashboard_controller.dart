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
    // Ensure all tab controllers are available
    if (!Get.isRegistered<HomeController>()) {
      Get.put(HomeController(), permanent: true);
    }
    if (!Get.isRegistered<AstrologerController>()) {
      Get.put(AstrologerController(), permanent: true);
    }
    if (!Get.isRegistered<LiveController>()) {
      Get.put(LiveController(), permanent: true);
    }
    if (!Get.isRegistered<ProfileController>()) {
      Get.put(ProfileController(), permanent: true);
    }
    if (!Get.isRegistered<ChatListController>()) {
      Get.put(ChatListController(), permanent: true);
    }
    if (!Get.isRegistered<ChatHistoryController>()) {
      Get.put(ChatHistoryController(), permanent: true);
    }
  }

  void changeTab(int index) {
    currentIndex.value = index;
    if (index == 1 && Get.isRegistered<AstrologerController>()) {
      Get.find<AstrologerController>().loadAstrologers();
    } else if (index == 2 && Get.isRegistered<LiveController>()) {
      Get.find<LiveController>().loadLiveStreams();
    } else if (index == 3 && Get.isRegistered<ChatHistoryController>()) {
      Get.find<ChatHistoryController>().fetchChatHistory();
    } else if (index == 4 && Get.isRegistered<ProfileController>()) {
      Get.find<ProfileController>().loadProfile();
    }
  }
}
