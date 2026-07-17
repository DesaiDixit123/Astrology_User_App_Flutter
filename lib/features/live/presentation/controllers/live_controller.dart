import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class LiveController extends GetxController {
  final RxList liveStreams = [].obs;
  final RxList gifts = [].obs;
  final RxMap activeStream = {}.obs;
  final RxList myQueueRequests = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isJoining = false.obs;

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    loadLiveStreams();
    loadGifts();
  }

  Future<void> loadLiveStreams() async {
    isLoading.value = true;
    final res = await _api.get(ApiConstants.liveStreams);
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      liveStreams.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> loadGifts() async {
    final res = await _api.get(ApiConstants.liveGifts);
    if (ApiService.isSuccess(res)) {
      gifts.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<Map<String, dynamic>?> joinStream(String streamId) async {
    isJoining.value = true;
    final res = await _api.post(ApiConstants.joinLive, data: {'live_stream_id': streamId});
    isJoining.value = false;
    if (ApiService.isSuccess(res)) {
      final data = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
      activeStream.value = data;
      return data;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return null;
    }
  }

  Future<void> sendGift({
    required String streamId,
    required String giftId,
    int quantity = 1,
  }) async {
    final res = await _api.post(ApiConstants.sendGift, data: {
      'live_stream_id': streamId,
      'gift_id': giftId,
      'quantity': quantity,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Gift sent! ❤️');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> requestCallInLive(String streamId, {String type = 'call'}) async {
    final res = await _api.post(ApiConstants.liveCallRequest, data: {
      'live_stream_id': streamId,
      'type': type,
    });
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      SnackbarUtil.success('Request sent! You are at position ${data?['queue_position']}.');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> refresh() => loadLiveStreams();
}
