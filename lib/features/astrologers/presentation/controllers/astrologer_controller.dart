import 'dart:async';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/utils/astrologer_utils.dart';

class AstrologerController extends GetxController {
  final RxList astrologers = [].obs;
  final RxList topAstrologers = [].obs;
  final RxList liveAstrologers = [].obs;
  final RxList following = [].obs;
  final RxMap selectedAstrologer = {}.obs;
  final RxBool isLoading = false.obs;
  final RxBool hasMore = true.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterType = ''.obs; // 'call', 'video_call', 'live'
  final RxBool isFreeChatEligible = false.obs;
  final RxBool isFreeChatEnabled = true.obs;
  final RxInt freeChatDurationMinutes = 1.obs;

  int _page = 1;
  final _api = ApiService.instance;
  IO.Socket? _socket;
  Timer? _statusRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    checkFreeChatEligibility();
    loadAstrologers();
    final args = Get.arguments;
    final astrologerId = (args is Map) ? args['_id']?.toString() : null;
    if (astrologerId != null && astrologerId.isNotEmpty) {
      refreshSelectedAstrologer(astrologerId);
    }
    _initSocket();
  }

  Future<void> checkFreeChatEligibility() async {
    try {
      final settingsRes = await _api.get(ApiConstants.freeChatSettings);
      if (ApiService.isSuccess(settingsRes)) {
        final settingsData = ApiService.getData(settingsRes) as Map<String, dynamic>?;
        if (settingsData != null) {
          isFreeChatEnabled.value = settingsData['is_enabled'] != false;
          freeChatDurationMinutes.value = settingsData['duration_minutes'] ?? 1;
        }
      }
    } catch (e) {
      print('Error fetching free chat settings in list: $e');
    }

    try {
      final profileRes = await _api.get(ApiConstants.profile);
      if (ApiService.isSuccess(profileRes)) {
        final profileData = ApiService.getData(profileRes) as Map<String, dynamic>?;
        if (profileData != null) {
          isFreeChatEligible.value = isFreeChatEnabled.value && (profileData['is_free_chat_used'] != true);
        }
      }
    } catch (e) {
      print('Error checking eligibility in list: $e');
    }
  }

  @override
  void onClose() {
    _statusRefreshTimer?.cancel();
    _socket?.disconnect();
    super.onClose();
  }

  void _initSocket() {
    _socket = IO.io(ApiConstants.baseUrl, IO.OptionBuilder()
      .setTransports(['websocket'])
      .build());

    _socket?.onConnect((_) => print('User App: Connected to Socket.io'));
    
    _socket?.on('astrologer_status_update', (data) {
      if (data is Map) {
        final astrologerId = data['astrologerId']?.toString();
        if (astrologerId != null) {
          _updateAstrologerStatusLocally(astrologerId, data);
          _scheduleStatusRefresh(astrologerId);
        }
      }
    });

    _socket?.onDisconnect((_) => print('User App: Disconnected from Socket.io'));
  }

  void _updateAstrologerStatusLocally(String id, Map statusData) {
    // Helper to update status in various lists
    void updateList(RxList list) {
      final index = list.indexWhere((a) => a['_id'] == id);
      if (index != -1) {
        final current = Map<String, dynamic>.from(list[index]);
        // Map snake_case from server to camelCase used in UI if necessary, 
        // or just keep both to be safe.
        if (statusData.containsKey('is_online')) {
          current['is_online'] = statusData['is_online'];
          current['isOnline'] = statusData['is_online'];
        }
        if (statusData.containsKey('is_call_available')) {
          current['is_call_available'] = statusData['is_call_available'];
          current['isCallEnabled'] = statusData['is_call_available'];
        }
        if (statusData.containsKey('is_chat_available')) {
          current['is_chat_available'] = statusData['is_chat_available'];
          current['isChatEnabled'] = statusData['is_chat_available'];
        }
        if (statusData.containsKey('is_video_call_available')) {
          current['is_video_call_available'] = statusData['is_video_call_available'];
          current['isVideoCallEnabled'] = statusData['is_video_call_available'];
        }
        list[index] = current;
      }
    }

    updateList(astrologers);
    updateList(topAstrologers);
    updateList(liveAstrologers);

    if (selectedAstrologer.isNotEmpty && selectedAstrologer['_id']?.toString() == id) {
      final current = Map<String, dynamic>.from(selectedAstrologer);
      if (statusData.containsKey('is_online')) {
        current['is_online'] = statusData['is_online'];
        current['isOnline'] = statusData['is_online'];
      }
      if (statusData.containsKey('is_call_available')) {
        current['is_call_available'] = statusData['is_call_available'];
        current['isCallEnabled'] = statusData['is_call_available'];
      }
      if (statusData.containsKey('is_chat_available')) {
        current['is_chat_available'] = statusData['is_chat_available'];
        current['isChatEnabled'] = statusData['is_chat_available'];
      }
      if (statusData.containsKey('is_video_call_available')) {
        current['is_video_call_available'] = statusData['is_video_call_available'];
        current['isVideoCallEnabled'] = statusData['is_video_call_available'];
      }
      selectedAstrologer.value = current;
    }
  }

  Future<void> loadAstrologers({bool refresh = false}) async {
    if (refresh) {
      _page = 1;
      hasMore.value = true;
      astrologers.clear();
      checkFreeChatEligibility();
    }
    if (!hasMore.value) return;
    isLoading.value = true;

    final res = await _api.get(ApiConstants.astrologers, queryParameters: {
      'page': _page,
      'limit': 20,
      if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
      if (filterType.value.isNotEmpty) 'available_for': filterType.value,
    });

    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      final docs = _normalizeAstrologers(data?['docs']);
      if (refresh) {
        astrologers.value = docs;
      } else {
        astrologers.addAll(docs);
      }
      hasMore.value = data?['hasNextPage'] == true;
      _page++;
    }
  }

  Future<void> loadTopAstrologers() async {
    final res = await _api.get(ApiConstants.topAstrologers);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      topAstrologers.value =
          data is List ? _normalizeAstrologers(data) : _normalizeAstrologers(data?['docs']);
    }
  }

  Future<void> loadLiveAstrologers() async {
    final res = await _api.get(ApiConstants.liveAstrologers);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      liveAstrologers.value =
          data is List ? _normalizeAstrologers(data) : _normalizeAstrologers(data?['docs']);
    }
  }

  Future<Map<String, dynamic>?> getAstrologerDetail(String id) async {
    final res = await _api.get('${ApiConstants.astrologers}/$id');
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        selectedAstrologer.value = _normalizeAstrologer(data);
      }
      return data;
    }
    return null;
  }

  Future<void> refreshSelectedAstrologer(String id) async {
    await getAstrologerDetail(id);
  }

  void _scheduleStatusRefresh(String astrologerId) {
    _statusRefreshTimer?.cancel();
    _statusRefreshTimer = Timer(const Duration(milliseconds: 400), () async {
      // NOTE: We don't call loadAstrologers(refresh: true) here to avoid full list blinking.
      // Local status updates from socket are handled immediately in _updateAstrologerStatusLocally.
      
      if (selectedAstrologer['_id']?.toString() == astrologerId) {
        await refreshSelectedAstrologer(astrologerId);
      }
    });
  }

  bool isFollowing(Map astrologer) {
    final id = (astrologer['_id'] ?? astrologer['id'])?.toString();
    if (id == null) return false;
    final flag = astrologer['is_following'] ?? astrologer['isFollowing'];
    if (flag is bool) return flag;
    return following.any((a) => (a['_id'] ?? a['id'])?.toString() == id);
  }

  int getFollowersCount(Map astrologer) {
    if (astrologer['followers'] is List) {
      return (astrologer['followers'] as List).length;
    }
    final raw = astrologer['followers_count'] ??
        astrologer['followersCount'] ??
        astrologer['totalFollowers'] ??
        astrologer['followerCount'];
    if (raw is num) return raw.toInt();
    return int.tryParse(raw?.toString() ?? '') ?? 0;
  }

  Future<void> toggleFollow(String astrologerId) async {
    final currentVal = selectedAstrologer['is_following'] as bool? ?? isFollowing(selectedAstrologer);
    final newVal = !currentVal;
    final currentCount = getFollowersCount(selectedAstrologer);
    final newCount = newVal ? currentCount + 1 : (currentCount > 0 ? currentCount - 1 : 0);

    selectedAstrologer['is_following'] = newVal;
    selectedAstrologer['followers_count'] = newCount;
    selectedAstrologer.refresh();

    final idx = astrologers.indexWhere((a) => (a['_id'] ?? a['id'])?.toString() == astrologerId);
    if (idx != -1) {
      final updated = Map<String, dynamic>.from(astrologers[idx]);
      updated['is_following'] = newVal;
      updated['followers_count'] = newCount;
      astrologers[idx] = updated;
    }

    final res = await _api.post(ApiConstants.follow, data: {'astrologer_id': astrologerId});
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      SnackbarUtil.success(data?['message'] ?? ApiService.getMessage(res));
      await loadFollowing();
      await refreshSelectedAstrologer(astrologerId);
    } else {
      selectedAstrologer['is_following'] = currentVal;
      selectedAstrologer['followers_count'] = currentCount;
      selectedAstrologer.refresh();
      if (idx != -1) {
        final updated = Map<String, dynamic>.from(astrologers[idx]);
        updated['is_following'] = currentVal;
        updated['followers_count'] = currentCount;
        astrologers[idx] = updated;
      }
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> loadFollowing() async {
    final res = await _api.get(ApiConstants.following);
    if (ApiService.isSuccess(res)) {
      following.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> submitReport(String astrologerId, String reason) async {
    final res = await _api.post(ApiConstants.report, data: {
      'astrologer_id': astrologerId,
      'reason': reason,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Report submitted successfully.');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Timer? _searchTimer;
  void search(String query) {
    searchQuery.value = query;
    _searchTimer?.cancel();
    _searchTimer = Timer(const Duration(milliseconds: 500), () {
      loadAstrologers(refresh: true);
    });
  }

  void setFilter(String type) {
    filterType.value = type;
    loadAstrologers(refresh: true);
  }

  List<Map<String, dynamic>> _normalizeAstrologers(dynamic list) {
    if (list is! List) return [];
    return list
        .whereType<Map>()
        .map<Map<String, dynamic>>(_normalizeAstrologer)
        .toList();
  }

  Map<String, dynamic> _normalizeAstrologer(Map raw) {
    final Map<String, dynamic> normalized = Map<String, dynamic>.from(raw);
    final personal = raw['personal_details'];
    final skillDetails = raw['skill_details'];

    // Basic identity
    normalized['name'] = AstrologerUtils.getLocalizedAstrologerName(raw);
    normalized['profilePic'] ??= personal is Map ? personal['profile_image'] : null;

    // Skills / specialization – prefer names from skill_details
    final skills = <String>[];
    void addSkills(dynamic list) {
      if (list is List) {
        for (final s in list) {
          if (s is Map && s['name'] != null) skills.add(s['name'].toString());
          if (s is String) skills.add(s);
        }
      }
    }
    if (skillDetails is Map) {
      addSkills(skillDetails['primary_skills']);
      addSkills(skillDetails['all_skills']);
      addSkills(skillDetails['category']);
    }
    if (skills.isEmpty) addSkills(raw['skills']); // fallback
    if (skills.isNotEmpty) {
      normalized['skills'] = skills;
      normalized['specialization'] = skills.first;
    }

    // Languages – prefer names from skill_details
    final langs = <String>[];
    void addLangs(dynamic list) {
      if (list is List) {
        for (final l in list) {
          if (l is Map && l['name'] != null) langs.add(l['name'].toString());
          if (l is String) langs.add(l);
        }
      }
    }
    if (skillDetails is Map) addLangs(skillDetails['language']);
    if (langs.isEmpty) addLangs(raw['languages']); // fallback
    if (langs.isNotEmpty) normalized['languages'] = langs;

    // Experience
    if (normalized['experience'] == null && skillDetails is Map) {
      normalized['experience'] = skillDetails['experience_years'];
    }

    // Pricing
    if (skillDetails is Map) {
      normalized['chatPrice'] =
          skillDetails['charge_per_min_inr'] ?? raw['charge_per_min_inr'];
      normalized['voicePrice'] = skillDetails['voice_charge_per_min_inr'] ??
          raw['voice_charge_per_min_inr'];
      normalized['videoPrice'] = skillDetails['video_charge_per_min_inr'] ??
          raw['video_charge_per_min_inr'];
    }

    if (normalized['pricePerMinute'] == null) {
      num? price = normalized['chatPrice'] ??
          normalized['voicePrice'] ??
          normalized['videoPrice'] ??
          raw['price'] ??
          raw['call_price'] ??
          raw['chat_price'];

      if (price != null) {
        normalized['pricePerMinute'] = price;
        normalized['price'] = price;
      }
    }

    // Total consultations fallback
    normalized['totalConsultations'] ??=
        raw['total_calls'] ?? raw['total_sessions'] ?? raw['totalConsultations'];

    return normalized;
  }
}
