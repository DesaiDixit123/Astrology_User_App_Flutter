import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/localization/app_language_controller.dart';

class KundliController extends GetxController {
  final RxBool isLoading = false.obs;
  final kundliNameController = TextEditingController();
  final kundliDobController = TextEditingController();
  final kundliTobController = TextEditingController();
  final kundliPlaceController = TextEditingController();
  
  final RxString kundliGender = 'Male'.obs;
  final RxBool timeUnknown = false.obs;
  String lat = '28.6139';
  String lon = '77.2090';

  final RxMap kundliResult = {}.obs;
  final RxList savedKundlis = [].obs;

  // Tabs State
  final RxInt selectedTabIndex = 0.obs;

  final _api = ApiService.instance;
  
  // Google Places API
  final String _googlePlacesApiKey = 'AIzaSyAVjTrh-XWVLhlagIJmtHod88KTqHl7tkE';
  final Dio _dio = Dio();

  @override
  void onInit() {
    super.onInit();
    fetchSavedKundlis();
  }

  @override
  void onClose() {
    kundliNameController.dispose();
    kundliDobController.dispose();
    kundliTobController.dispose();
    kundliPlaceController.dispose();
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

  Future<void> getKundli() async {
    if (kundliNameController.text.isEmpty) {
      SnackbarUtil.error('Please enter your name.');
      return;
    }
    if (kundliDobController.text.isEmpty) {
      SnackbarUtil.error('Please enter DOB (DD/MM/YYYY).');
      return;
    }
    if (!timeUnknown.value && kundliTobController.text.isEmpty) {
      SnackbarUtil.error('Please enter TOB (HH:MM) or check "Don\'t know birth time".');
      return;
    }
    if (kundliPlaceController.text.isEmpty) {
      SnackbarUtil.error('Please select Place of Birth.');
      return;
    }
    
    isLoading.value = true;
    final res = await _api.post(ApiConstants.kundli, data: {
      'name': kundliNameController.text.trim(),
      'gender': kundliGender.value,
      'dob': kundliDobController.text.trim(),
      'tob': timeUnknown.value ? '12:00' : kundliTobController.text.trim(),
      'time_unknown': timeUnknown.value,
      'place': kundliPlaceController.text.trim(),
      'lat': lat,
      'lon': lon,
      'timezone': '5.5',
      'lang': Get.find<AppLanguageController>().currentLanguageCode,
    });
    isLoading.value = false;
    
    if (ApiService.isSuccess(res)) {
      kundliResult.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
      selectedTabIndex.value = 0; // Reset to Basic Details tab
      fetchSavedKundlis(); // Refresh saved kundlis
      SnackbarUtil.success('Kundli generated successfully!');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> fetchSavedKundlis() async {
    final res = await _api.get(ApiConstants.savedKundlis);
    if (ApiService.isSuccess(res)) {
      savedKundlis.value = List.from(ApiService.getData(res) ?? []);
    }
  }
}
