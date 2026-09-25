import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/localization/app_language_controller.dart';

class MatchmakingController extends GetxController {
  final RxBool isLoading = false.obs;

  final mNameController = TextEditingController();
  final mDobController = TextEditingController();
  final mTobController = TextEditingController();
  final mPlaceController = TextEditingController();
  final RxBool mTimeUnknown = false.obs;
  String mLat = '28.6139';
  String mLon = '77.2090';

  final fNameController = TextEditingController();
  final fDobController = TextEditingController();
  final fTobController = TextEditingController();
  final fPlaceController = TextEditingController();
  final RxBool fTimeUnknown = false.obs;
  String fLat = '28.6139';
  String fLon = '77.2090';

  final RxMap matchmakingResult = {}.obs;
  final RxList matchingHistory = [].obs;

  // Tabs State
  final RxInt selectedTabIndex = 0.obs;

  final _api = ApiService.instance;

  // Google Places API (Placeholder)
  final String _googlePlacesApiKey = 'AIzaSyAVjTrh-XWVLhlagIJmtHod88KTqHl7tkE';
  final Dio _dio = Dio();
  
  final ScrollController mainScrollController = ScrollController();
  final GlobalKey resultKey = GlobalKey();

  @override
  void onInit() {
    super.onInit();
    fetchMatchingHistory();
  }

  @override
  void onClose() {
    mainScrollController.dispose();
    mNameController.dispose();
    mDobController.dispose();
    mTobController.dispose();
    mPlaceController.dispose();
    fNameController.dispose();
    fDobController.dispose();
    fTobController.dispose();
    fPlaceController.dispose();
    super.onClose();
  }

  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final response = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'json',
          'q': query,
          'limit': '5',
          'addressdetails': '1',
        },
        options: Options(headers: {'User-Agent': 'AstrologyUserApp/1.0'}),
      );
      if (response.statusCode == 200 && response.data is List && (response.data as List).isNotEmpty) {
        final predictions = response.data as List;
        return predictions
            .map(
              (p) => {
                'description': p['display_name']?.toString() ?? p['name']?.toString() ?? query,
                'lat': p['lat']?.toString() ?? '23.0225',
                'lon': p['lon']?.toString() ?? '72.5714',
                'place_id': p['place_id']?.toString() ?? '',
              },
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error in Nominatim place search: $e');
    }
    
    // Fallback list of popular cities
    final popularCities = [
      {'description': 'Ahmedabad, Gujarat, India', 'lat': '23.0225', 'lon': '72.5714'},
      {'description': 'Bhavnagar, Gujarat, India', 'lat': '21.7645', 'lon': '72.1519'},
      {'description': 'Surat, Gujarat, India', 'lat': '21.1702', 'lon': '72.8311'},
      {'description': 'Vadodara, Gujarat, India', 'lat': '22.3072', 'lon': '73.1812'},
      {'description': 'Rajkot, Gujarat, India', 'lat': '22.3039', 'lon': '70.8022'},
      {'description': 'Mumbai, Maharashtra, India', 'lat': '19.0760', 'lon': '72.8777'},
      {'description': 'Delhi, India', 'lat': '28.6139', 'lon': '77.2090'},
      {'description': 'Bengaluru, Karnataka, India', 'lat': '12.9716', 'lon': '77.5946'},
      {'description': 'Jaipur, Rajasthan, India', 'lat': '26.9124', 'lon': '75.7873'},
      {'description': 'Indore, Madhya Pradesh, India', 'lat': '22.7196', 'lon': '75.8577'},
    ];
    return popularCities.where((c) => c['description']!.toLowerCase().contains(query.toLowerCase())).toList();
  }

  Future<Map<String, String>?> getPlaceDetails(String placeId) async {
    return null;
  }

  Future<Map<String, String>> resolveCoordinates(String place) async {
    if (place.trim().isEmpty) return {'lat': '23.0225', 'lon': '72.5714'};
    try {
      final res = await _dio.get(
        'https://nominatim.openstreetmap.org/search',
        queryParameters: {
          'format': 'json',
          'q': place,
          'limit': '1',
        },
        options: Options(headers: {'User-Agent': 'AstrologyUserApp/1.0'}),
      );
      if (res.statusCode == 200 && res.data is List && (res.data as List).isNotEmpty) {
        final first = (res.data as List).first;
        return {
          'lat': first['lat']?.toString() ?? '23.0225',
          'lon': first['lon']?.toString() ?? '72.5714',
        };
      }
    } catch (e) {
      debugPrint('Error resolving coordinates: $e');
    }
    return {'lat': '23.0225', 'lon': '72.5714'};
  }

  Future<void> getMatchmaking() async {
    if (mNameController.text.isEmpty || fNameController.text.isEmpty) {
      SnackbarUtil.error('Please enter name for both partners.');
      return;
    }
    if (mDobController.text.isEmpty || fDobController.text.isEmpty) {
      SnackbarUtil.error('Please enter DOB (DD/MM/YYYY) for both partners.');
      return;
    }
    if ((!mTimeUnknown.value && mTobController.text.isEmpty) ||
        (!fTimeUnknown.value && fTobController.text.isEmpty)) {
      SnackbarUtil.error(
        'Please enter TOB (HH:MM) or check "Don\'t know birth time" for both partners.',
      );
      return;
    }
    if (mPlaceController.text.isEmpty || fPlaceController.text.isEmpty) {
      SnackbarUtil.error('Please select Place of Birth for both partners.');
      return;
    }

    isLoading.value = true;
    matchmakingResult.clear(); // Clear previous result state immediately

    final boyCoords = await resolveCoordinates(mPlaceController.text.trim());
    mLat = boyCoords['lat']!;
    mLon = boyCoords['lon']!;

    final girlCoords = await resolveCoordinates(fPlaceController.text.trim());
    fLat = girlCoords['lat']!;
    fLon = girlCoords['lon']!;

    final payload = {
      'boy_name': mNameController.text.trim(),
      'boy_dob': mDobController.text.trim(),
      'boy_tob': mTimeUnknown.value ? '12:00' : mTobController.text.trim(),
      'boy_time_unknown': mTimeUnknown.value,
      'boy_lat': mLat,
      'boy_lon': mLon,
      'boy_place': mPlaceController.text.trim(),
      'boy_birth_place': mPlaceController.text.trim(),
      'boy_tz': '5.5',
      'girl_name': fNameController.text.trim(),
      'girl_dob': fDobController.text.trim(),
      'girl_tob': fTimeUnknown.value ? '12:00' : fTobController.text.trim(),
      'girl_time_unknown': fTimeUnknown.value,
      'girl_lat': fLat,
      'girl_lon': fLon,
      'girl_place': fPlaceController.text.trim(),
      'girl_birth_place': fPlaceController.text.trim(),
      'girl_tz': '5.5',
      'lang': Get.find<AppLanguageController>().currentLanguageCode,
    };

    try {
      final responses = await Future.wait([
        _api.post(ApiConstants.matchingBasicDetails, data: payload),
        _api.post(ApiConstants.matchingAshtakoot, data: payload),
        _api.post(ApiConstants.matchingPlanetDetails, data: payload),
        _api.post(ApiConstants.matchingCharts, data: payload),
        _api.post(ApiConstants.matchingManglik, data: payload),
      ]);

      final basicRes = responses[0];
      final ashtakootRes = responses[1];
      final planetsRes = responses[2];
      final chartsRes = responses[3];
      final manglikRes = responses[4];

      Map<String, dynamic> safeMap(dynamic input) {
        if (input is Map<String, dynamic>) return input;
        if (input is Map) return Map<String, dynamic>.from(input);
        return <String, dynamic>{};
      }

      if (basicRes != null || ashtakootRes != null) {
        final Map<String, dynamic> combinedData = {};
        combinedData['payload'] = payload;

        final basicData = safeMap(ApiService.getData(basicRes));
        final ashtakootData = safeMap(ApiService.getData(ashtakootRes));
        final planetsData = safeMap(ApiService.getData(planetsRes));
        final chartsData = safeMap(ApiService.getData(chartsRes));
        final manglikData = safeMap(ApiService.getData(manglikRes));

        combinedData['basic'] = basicData;
        combinedData['ashtakoot'] = ashtakootData;
        combinedData['planets'] = planetsData;
        combinedData['charts'] = chartsData;
        combinedData['manglik'] = manglikData;

        // Legacy accessors
        combinedData['boy'] = safeMap(basicData['boy'] ?? basicData['boy_details']);
        combinedData['girl'] = safeMap(basicData['girl'] ?? basicData['girl_details']);
        combinedData['recommendation'] = ashtakootData['bot_response'] ??
            basicData['recommendation'] ??
            'Kundali matching completed.';

        // Also fetch individual Kundlis for Nakshatra & Pada enrichment if missing
        try {
          final futures = await Future.wait([
            _api.post(ApiConstants.kundli, data: {
              'name': mNameController.text.trim(),
              'gender': 'Male',
              'dob': mDobController.text.trim(),
              'tob': mTimeUnknown.value ? '12:00' : mTobController.text.trim(),
              'time_unknown': mTimeUnknown.value,
              'place': mPlaceController.text.trim(),
              'lat': mLat,
              'lon': mLon,
              'timezone': '5.5',
              'lang': Get.find<AppLanguageController>().currentLanguageCode,
            }),
            _api.post(ApiConstants.kundli, data: {
              'name': fNameController.text.trim(),
              'gender': 'Female',
              'dob': fDobController.text.trim(),
              'tob': fTimeUnknown.value ? '12:00' : fTobController.text.trim(),
              'time_unknown': fTimeUnknown.value,
              'place': fPlaceController.text.trim(),
              'lat': fLat,
              'lon': fLon,
              'timezone': '5.5',
              'lang': Get.find<AppLanguageController>().currentLanguageCode,
            }),
          ]);

          Map<String, dynamic> boyAstroData = {};
          Map<String, dynamic> girlAstroData = {};
          if (ApiService.isSuccess(futures[0])) {
            boyAstroData = Map<String, dynamic>.from(ApiService.getData(futures[0]) ?? {});
          }
          if (ApiService.isSuccess(futures[1])) {
            girlAstroData = Map<String, dynamic>.from(ApiService.getData(futures[1]) ?? {});
          }

          final boyMap = Map<String, dynamic>.from(combinedData['boy'] as Map? ?? {});
          final girlMap = Map<String, dynamic>.from(combinedData['girl'] as Map? ?? {});

          Map? getNestedMap(Map<String, dynamic> source, List<String> keys) {
            for (final k in keys) {
              if (source[k] is Map) return source[k] as Map;
            }
            return null;
          }

          final boyAvakhada = getNestedMap(boyAstroData, ['avakhada_details', 'panchang_details', 'astro_details']);
          boyMap['nakshatra'] ??= boyAvakhada?['nakshatra'] ?? boyAstroData['nakshatra'] ?? boyAstroData['nakshatra_name'];
          boyMap['nakshatra_pada'] ??= boyAvakhada?['nakshatra_pada'] ?? boyAvakhada?['pada'] ?? boyAstroData['nakshatra_pada'] ?? boyAstroData['pada'];
          boyMap['janam_rashi'] ??= boyAvakhada?['rasi'] ?? boyAstroData['rasi'] ?? boyAstroData['rashi'];
          boyMap['rashi_lord'] ??= boyAvakhada?['rasi_lord'] ?? boyAstroData['rasi_lord'] ?? boyAstroData['rashi_lord'];

          final girlAvakhada = getNestedMap(girlAstroData, ['avakhada_details', 'panchang_details', 'astro_details']);
          girlMap['nakshatra'] ??= girlAvakhada?['nakshatra'] ?? girlAstroData['nakshatra'] ?? girlAstroData['nakshatra_name'];
          girlMap['nakshatra_pada'] ??= girlAvakhada?['nakshatra_pada'] ?? girlAvakhada?['pada'] ?? girlAstroData['nakshatra_pada'] ?? girlAstroData['pada'];
          girlMap['janam_rashi'] ??= girlAvakhada?['rasi'] ?? girlAstroData['rasi'] ?? girlAstroData['rashi'];
          girlMap['rashi_lord'] ??= girlAvakhada?['rasi_lord'] ?? girlAstroData['rasi_lord'] ?? girlAstroData['rashi_lord'];

          combinedData['boy'] = boyMap;
          combinedData['girl'] = girlMap;
        } catch (e) {
          debugPrint('Error enriching nakshatra details: $e');
        }

        matchmakingResult.value = combinedData;
        selectedTabIndex.value = 0;
        fetchMatchingHistory();

        Future.delayed(const Duration(milliseconds: 300), () {
          if (resultKey.currentContext != null) {
            Scrollable.ensureVisible(
              resultKey.currentContext!,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              alignment: 0.1,
            );
          }
        });
      } else {
        SnackbarUtil.error(ApiService.getMessage(basicRes));
      }
    } catch (e) {
      debugPrint('Error in getMatchmaking: $e');
      SnackbarUtil.error('Failed to calculate Kundali Matching. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchMatchingHistory() async {
    final res = await _api.get(ApiConstants.matchingHistory);
    if (ApiService.isSuccess(res)) {
      matchingHistory.value = List.from(ApiService.getData(res) ?? []);
    }
  }
}
