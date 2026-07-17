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
    if (query.isEmpty) return [];
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json',
        queryParameters: {
          'input': query,
          'key': _googlePlacesApiKey,
          'types': '(cities)',
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final predictions = response.data['predictions'] as List;
        return predictions
            .map(
              (p) => {
                'description': p['description'],
                'place_id': p['place_id'],
              },
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error searching places: $e');
    }
    return [];
  }

  Future<Map<String, String>?> getPlaceDetails(String placeId) async {
    try {
      final response = await _dio.get(
        'https://maps.googleapis.com/maps/api/place/details/json',
        queryParameters: {
          'place_id': placeId,
          'key': _googlePlacesApiKey,
          'fields': 'geometry',
        },
      );
      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final location = response.data['result']['geometry']['location'];
        return {
          'lat': location['lat'].toString(),
          'lon': location['lng'].toString(),
        };
      }
    } catch (e) {
      debugPrint('Error getting place details: $e');
    }
    return null;
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
    final res = await _api.post(
      ApiConstants.kundliMatch,
      data: {
        'boy_name': mNameController.text.trim(),
        'boy_dob': mDobController.text.trim(),
        'boy_tob': mTimeUnknown.value ? '12:00' : mTobController.text.trim(),
        'boy_time_unknown': mTimeUnknown.value,
        'boy_lat': mLat,
        'boy_lon': mLon,
        'boy_place': mPlaceController.text.trim(),
        'boy_tz': '5.5',
        'girl_name': fNameController.text.trim(),
        'girl_dob': fDobController.text.trim(),
        'girl_tob': fTimeUnknown.value ? '12:00' : fTobController.text.trim(),
        'girl_time_unknown': fTimeUnknown.value,
        'girl_lat': fLat,
        'girl_lon': fLon,
        'girl_place': fPlaceController.text.trim(),
        'girl_tz': '5.5',
        'lang': Get.find<AppLanguageController>().currentLanguageCode,
      },
    );
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      matchmakingResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
      selectedTabIndex.value = 0; // Reset to Basic Details tab
      fetchMatchingHistory(); // Refresh history
      
      Future.delayed(const Duration(milliseconds: 300), () {
        if (resultKey.currentContext != null) {
          Scrollable.ensureVisible(
            resultKey.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            alignment: 0.1, // Aligns to the upper portion of the viewport avoiding the appbar
          );
        }
      });
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> fetchMatchingHistory() async {
    final res = await _api.get(ApiConstants.matchingHistory);
    if (ApiService.isSuccess(res)) {
      matchingHistory.value = List.from(ApiService.getData(res) ?? []);
    }
  }
}
