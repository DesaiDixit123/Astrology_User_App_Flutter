import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/astrologer_utils.dart';

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
    isLoading.value = banners.isEmpty;
    if (banners.isEmpty) {
      banners.value = _defaultBanners;
    }

    try {
      // Execute free chat settings, profile, and home API calls in PARALLEL for ultra-fast loading
      final results = await Future.wait([
        _api.get(ApiConstants.home),
        _api.get(ApiConstants.freeChatSettings),
        _api.get(ApiConstants.profile),
      ]);

      final homeRes = results[0];
      final settingsRes = results[1];
      final profileRes = results[2];

      // Parse free chat settings
      if (ApiService.isSuccess(settingsRes)) {
        final settingsData = ApiService.getData(settingsRes) as Map<String, dynamic>?;
        if (settingsData != null) {
          isFreeChatEnabled.value = settingsData['is_enabled'] != false;
          freeChatDurationMinutes.value = settingsData['duration_minutes'] ?? 1;
        }
      }

      // Parse profile eligibility
      if (ApiService.isSuccess(profileRes)) {
        final profileData = ApiService.getData(profileRes) as Map<String, dynamic>?;
        if (profileData != null) {
          isFreeChatEligible.value = isFreeChatEnabled.value && (profileData['is_free_chat_used'] != true);
        }
      }

      // Parse home data
      if (ApiService.isSuccess(homeRes)) {
        final data = ApiService.getData(homeRes) as Map<String, dynamic>?;
        if (data != null) {
          final fetchedBanners = List.from(data['banners'] ?? []);
          final validRemoteBanners = fetchedBanners.where((b) {
            final img = (b['image'] ?? b['banner'] ?? '').toString();
            return img.isNotEmpty && !img.contains('banner_1.png') && !img.contains('banner_2.png') && !img.contains('banner_3.png');
          }).toList();

          if (validRemoteBanners.isNotEmpty) {
            banners.value = validRemoteBanners;
          }
          topAstrologers.value = _normalizeAstrologers(data['topAstrologers']);
          liveAstrologers.value = _normalizeAstrologers(data['liveAstrologers']);
          blogs.value = List.from(data['blogs'] ?? []);
          videos.value = List.from(data['videos'] ?? []);
        }
      } else {
        // Fallback: fetch individually in parallel
        await Future.wait([
          _fetchBanners(),
          _fetchTopAstrologers(),
          _fetchLiveAstrologers(),
          _fetchBlogs(),
          _fetchVideos(),
        ]);
      }
    } catch (e) {
      print('Error loading home data: $e');
    } finally {
      isLoading.value = false;
      if (banners.isNotEmpty) startBannerAutoScroll();
    }
  }

  static List get _defaultBanners {
    final lang = Get.locale?.languageCode ?? 'en';
    if (lang == 'gu') {
      return [
        {
          'title': 'વૈદિક જ્યોતિષ પરામર્શ',
          'subtitle': 'તમારું ભાગ્ય જાણો | સચોટ કુંડળી વિશ્લેષણ',
          'image': 'assets/images/banner_1.jpg',
          'isAsset': true,
        },
        {
          'title': 'પવિત્ર કુંડળી માર્ગદર્શન',
          'subtitle': 'ટોચના ચકાસાયેલ વૈદિક જ્યોતિષીઓ સાથે જોડાઓ',
          'image': 'assets/images/banner_2.jpg',
          'isAsset': true,
        },
        {
          'title': 'લાઇવ જ્યોતિષીય સલાહ',
          'subtitle': 'વ્યક્તિગત ચાર્ટ રીડિંગ અને દૈનિક આધ્યાત્મિક જ્ઞાન',
          'image': 'assets/images/banner_3.jpg',
          'isAsset': true,
        },
      ];
    } else if (lang == 'hi') {
      return [
        {
          'title': 'वैदिक ज्योतिष परामर्श',
          'subtitle': 'अपना भाग्य जानें | प्रामाणिक कुंडली विश्लेषण',
          'image': 'assets/images/banner_1.jpg',
          'isAsset': true,
        },
        {
          'title': 'पवित्र कुंडली मार्गदर्शन',
          'subtitle': 'शीर्ष सत्यापित वैदिक ज्योतिषियों से जुड़ें',
          'image': 'assets/images/banner_2.jpg',
          'isAsset': true,
        },
        {
          'title': 'लाइव ज्योतिष सलाह',
          'subtitle': 'व्यक्तिगत चार्ट रीडिंग और दैनिक आध्यात्मिक ज्ञान',
          'image': 'assets/images/banner_3.jpg',
          'isAsset': true,
        },
      ];
    }
    return [
      {
        'title': 'Vedic Astrology Consultation',
        'subtitle': 'Unveil Your Destiny | Authentic Kundali Readings',
        'image': 'assets/images/banner_1.jpg',
        'isAsset': true,
      },
      {
        'title': 'Sacred Kundali Guidance',
        'subtitle': 'Connect with Top Verified Vedic Astrologers',
        'image': 'assets/images/banner_2.jpg',
        'isAsset': true,
      },
      {
        'title': 'Live Astrology Advice',
        'subtitle': 'Personalized Chart Readings & Daily Cosmic Wisdom',
        'image': 'assets/images/banner_3.jpg',
        'isAsset': true,
      },
    ];
  }

  Future<void> _fetchBanners() async {
    final res = await _api.get(ApiConstants.banners);
    if (ApiService.isSuccess(res)) {
      final fetched = List.from(ApiService.getData(res) ?? []);
      final validBanners = fetched.where((b) {
        final img = (b['image'] ?? b['banner'] ?? '').toString();
        return img.isNotEmpty && !img.contains('banner_1.png') && !img.contains('banner_2.png') && !img.contains('banner_3.png');
      }).toList();
      banners.value = validBanners.isNotEmpty ? validBanners : _defaultBanners;
    } else {
      banners.value = _defaultBanners;
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

  Future<void> _fetchVideos() async {
    final res = await _api.get(ApiConstants.videos);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      videos.value = List.from(data is List ? data : (data?['docs'] ?? []));
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

      // Name & profile extraction
      normalized['name'] = AstrologerUtils.getLocalizedAstrologerName(target);

      String? extractedPic = target['profilePic']?.toString() ?? target['profile_pic']?.toString() ?? target['profile_image']?.toString();
      if ((extractedPic == null || extractedPic.isEmpty) && personal is Map) {
        extractedPic = personal['profile_image']?.toString() ?? personal['profile_pic']?.toString();
      }
      normalized['profilePic'] = extractedPic ?? '';

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
