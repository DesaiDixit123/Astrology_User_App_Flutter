import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class BlogController extends GetxController {
  final RxList blogs = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;

  int _page = 1;
  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadBlogs();
  }

  Future<void> loadBlogs({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      blogs.clear();
    }
    if (!hasMore.value) return;
    isLoading.value = true;
    final res = await _api.post(ApiConstants.blogs, data: {'page': _page, 'limit': 20});
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      final docs = List.from(data?['docs'] ?? []);
      if (refresh) {
        blogs.value = docs;
      } else {
        blogs.addAll(docs);
      }
      hasMore.value = data?['hasNextPage'] == true;
      _page++;
    }
  }

  Future<void> toggleLike(String blogId) async {
    final res = await _api.post(ApiConstants.blogLike, data: {'blog_id': blogId});
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      // Update the likes count in the list
      final index = blogs.indexWhere((b) => b['_id'] == blogId);
      if (index >= 0) {
        blogs[index] = Map<String, dynamic>.from(blogs[index])
          ..['is_liked'] = data?['is_liked']
          ..['likes_count'] = data?['likes_count'];
        blogs.refresh();
      }
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> reportBlog(String blogId, String reason) async {
    final res = await _api.post(ApiConstants.blogReport, data: {
      'blog_id': blogId,
      'reason': reason,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Blog reported. Our team will review it.');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }
}
