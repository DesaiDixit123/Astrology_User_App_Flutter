import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';

class HomeController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxList banners = [].obs;
  final RxList topAstrologers = [].obs;
  final RxList liveAstrologers = [].obs;
  final RxList feedbacks = [].obs;
  final RxList videos = [].obs;
  final RxList blogs = [].obs;
  final RxBool isFreeChatEligible = false.obs;
  final RxBool isFreeChatEnabled = true.obs;
  final RxInt freeChatDurationMinutes = 1.obs;

  late PageController bannerPageController;
  Timer? bannerTimer;
  final RxInt currentBannerIndex = 0.obs;

  final _api = ApiService.instance;
  IO.Socket? _socket;
  Timer? _statusRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    bannerPageController = PageController();
    loadData();
    _initSocket();
  }

  @override
  void onClose() {
    bannerTimer?.cancel();
    _statusRefreshTimer?.cancel();
    bannerPageController.dispose();
    _socket?.disconnect();
    super.onClose();
  }

  void _initSocket() {
    _socket = IO.io(
      ApiConstants.baseUrl,
      IO.OptionBuilder().setTransports(['websocket']).build(),
    );

    _socket?.on('astrologer_status_update', (data) {
      if (data is Map) {
        final astrologerId = data['astrologerId']?.toString();
        if (astrologerId != null && astrologerId.isNotEmpty) {
          _updateAstrologerStatusLocally(astrologerId, data);
          _scheduleStatusRefresh();
        }
      }
    });
  }

  void _updateAstrologerStatusLocally(String astrologerId, Map statusData) {
    Map<String, dynamic> _updatedAstrologer(Map item) {
      final current = Map<String, dynamic>.from(item);
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
      return current;
    }

    topAstrologers.value = topAstrologers
        .map((item) => item['_id'] == astrologerId ? _updatedAstrologer(item) : item)
        .toList();

    liveAstrologers.value = liveAstrologers.map((item) {
      if (item['_id'] == astrologerId) {
        return _updatedAstrologer(item);
      }

      final partner = item['partner'];
      if (partner is Map && partner['_id'] == astrologerId) {
        final updated = Map<String, dynamic>.from(item);
        updated['partner'] = _updatedAstrologer(partner);
        updated.addAll({
          'is_online': updated['partner']['is_online'],
          'isOnline': updated['partner']['isOnline'],
          'is_call_available': updated['partner']['is_call_available'],
          'isCallEnabled': updated['partner']['isCallEnabled'],
          'is_chat_available': updated['partner']['is_chat_available'],
          'isChatEnabled': updated['partner']['isChatEnabled'],
          'is_video_call_available': updated['partner']['is_video_call_available'],
          'isVideoCallEnabled': updated['partner']['isVideoCallEnabled'],
        });
        return updated;
      }

      return item;
    }).toList();
  }

  void startBannerAutoScroll() {
    bannerTimer?.cancel();
    bannerTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (banners.isNotEmpty) {
        final nextPage = (currentBannerIndex.value + 1) % banners.length;
        if (bannerPageController.hasClients) {
          bannerPageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      }
    });
  }

  Future<void> loadData() async {
    isLoading.value = true;

    // Fetch free chat settings from backend
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
      print('Error fetching free chat settings in home: $e');
    }

    // Fetch user profile to check free chat eligibility
    try {
      final profileRes = await _api.get(ApiConstants.profile);
      if (ApiService.isSuccess(profileRes)) {
        final profileData = ApiService.getData(profileRes) as Map<String, dynamic>?;
        if (profileData != null) {
          isFreeChatEligible.value = isFreeChatEnabled.value && (profileData['is_free_chat_used'] != true);
        }
      }
    } catch (e) {
      print('Error fetching profile in home: $e');
    }

    // Fetch home data (combined endpoint) — falls back to individual if needed
    final homeRes = await _api.get(ApiConstants.home);
    if (ApiService.isSuccess(homeRes)) {
      final data = ApiService.getData(homeRes) as Map<String, dynamic>?;
      if (data != null) {
        banners.value = List.from(data['banners'] ?? []);
        topAstrologers.value = _normalizeAstrologers(data['topAstrologers']);
        liveAstrologers.value = _normalizeAstrologers(data['liveAstrologers']);
        blogs.value = List.from(data['blogs'] ?? []);
      }
    } else {
      // Fallback: fetch individually
      await Future.wait([
        _fetchBanners(),
        _fetchTopAstrologers(),
        _fetchLiveAstrologers(),
        _fetchBlogs()
      ]);
    }

    isLoading.value = false;
    if (banners.isNotEmpty) startBannerAutoScroll();
  }

  Future<void> _fetchBanners() async {
    final res = await _api.get(ApiConstants.banners);
    if (ApiService.isSuccess(res)) {
      banners.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> _fetchTopAstrologers() async {
    final res = await _api.get(ApiConstants.topAstrologers);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      topAstrologers.value =
          data is List ? _normalizeAstrologers(data) : _normalizeAstrologers(data?['docs']);
    }
  }

  Future<void> _fetchLiveAstrologers() async {
    final res = await _api.get(ApiConstants.liveAstrologers);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      liveAstrologers.value =
          data is List ? _normalizeAstrologers(data) : _normalizeAstrologers(data?['docs']);
    }
  }

  Future<void> _fetchBlogs() async {
    final res = await _api.post(ApiConstants.blogs, data: {'limit': 5});
    if (ApiService.isSuccess(res)) {
      blogs.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }

  Future<void> refresh() => loadData();

  void _scheduleStatusRefresh() {
    _statusRefreshTimer?.cancel();
    _statusRefreshTimer = Timer(const Duration(milliseconds: 400), () {
      _fetchTopAstrologers();
      _fetchLiveAstrologers();
    });
  }

  /// Map new backend shape to the UI-friendly keys the app expects.
  List<Map<String, dynamic>> _normalizeAstrologers(dynamic list) {
    if (list is! List) return [];
    return list.map<Map<String, dynamic>>((raw) {
      if (raw is! Map) return {};
      
      // Handle live stream object containing a 'partner' field
      final Map<String, dynamic> target = Map<String, dynamic>.from(raw);
      if (raw['partner'] is Map) {
        final partnerMap = Map<String, dynamic>.from(raw['partner']);
        partnerMap.forEach((key, val) {
          if (key != '_id' && key != 'thumbnail' && key != 'status') {
            target[key] = val;
          }
        });
      }

      final Map<String, dynamic> normalized = Map<String, dynamic>.from(target);
      final personal = target['personal_details'];
      final skillDetails = target['skill_details'];

      // Name & profile
      normalized.putIfAbsent('name', () => personal is Map ? personal['name'] : null);
      normalized.putIfAbsent(
        'profilePic',
        () => personal is Map ? personal['profile_image'] : null,
      );

      // Skills / specialization – prefer names from skill_details
      final List<String> skills = [];
      void addSkills(dynamic items) {
        if (items is List) {
          for (final s in items) {
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
      if (skills.isNotEmpty) {
        normalized['skills'] = skills;
        normalized['specialization'] = skills.first;
      }

      // Experience
      if (normalized['experience'] == null && skillDetails is Map) {
        final exp = skillDetails['experience_years'];
        if (exp != null) normalized['experience'] = exp;
      }

      // Languages – prefer names from skill_details
      final List<String> langs = [];
      void addLangs(dynamic items) {
        if (items is List) {
          for (final l in items) {
            if (l is Map && l['name'] != null) langs.add(l['name'].toString());
            if (l is String) langs.add(l);
          }
        }
      }
      if (skillDetails is Map) addLangs(skillDetails['language']);
      if (langs.isNotEmpty) {
        normalized['languages'] = langs;
      }

      // Pricing (INR first, fallback USD)
      if (normalized['pricePerMinute'] == null && skillDetails is Map) {
        final priceInr = skillDetails['charge_per_min_inr'] ?? skillDetails['report_charge_per_min_inr'];
        final priceUsd = skillDetails['charge_per_min_usd'] ?? skillDetails['report_charge_per_min_usd'];
        final price = priceInr ?? priceUsd ?? normalized['price'];
        if (price != null) {
          normalized['pricePerMinute'] = price;
          normalized['price'] = price;
        }
      }

      return normalized;
    }).toList();
  }
}
