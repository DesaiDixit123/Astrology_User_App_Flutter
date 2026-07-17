import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/utils/snackbar_util.dart';

class NotificationController extends GetxController {
  final RxList notifications = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  int _page = 1;
  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      notifications.clear();
    }
    if (!hasMore.value) return;

    isLoading.value = true;
    try {
      final res = await _api.get('/customer/notifications', queryParameters: {
        'page': _page,
        'limit': 20,
      });

      if (ApiService.isSuccess(res)) {
        final data = ApiService.getData(res) as Map<String, dynamic>?;
        final docs = List.from(data?['docs'] ?? []);
        if (refresh) {
          notifications.value = docs;
        } else {
          notifications.addAll(docs);
        }

        final int totalPages = data?['totalPages'] ?? 1;
        if (_page >= totalPages || docs.isEmpty) {
          hasMore.value = false;
        } else {
          _page++;
        }
      }
    } catch (e) {
      print('Error fetching notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final res = await _api.post('/customer/notifications/read-all');
      if (ApiService.isSuccess(res)) {
        // Update all locally to is_read = true
        notifications.value = notifications.map((n) {
          final updated = Map.from(n);
          updated['is_read'] = true;
          return updated;
        }).toList();
        SnackbarUtil.success('All notifications marked as read');
      }
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }
}
