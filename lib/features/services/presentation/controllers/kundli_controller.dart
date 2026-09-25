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
    kundliResult.clear();

    final coords = await resolveCoordinates(kundliPlaceController.text.trim());
    lat = coords['lat']!;
    lon = coords['lon']!;

    final currentLang = Get.find<AppLanguageController>().currentLanguageCode;

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
      'lang': currentLang,
    });
    
    if (ApiService.isSuccess(res)) {
      Map<String, dynamic> data = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
      final reportId = data['report_id'] ?? data['kundliid'] ?? data['id'] ?? data['_id'];
      
      if (reportId != null && reportId.toString().isNotEmpty) {
        try {
          final detailRes = await _api.post(
            ApiConstants.kundliGetDetails,
            data: {
              'kundliid': reportId.toString(),
              'lang': currentLang,
            },
          );
          if (ApiService.isSuccess(detailRes)) {
            final detailData = Map<String, dynamic>.from(ApiService.getData(detailRes) ?? {});
            data.addAll(detailData);
          }
        } catch (e) {
          debugPrint('Error fetching detailed Kundli report: $e');
        }
      }

      kundliResult.value = data;
      selectedTabIndex.value = 0; // Reset to Basic Details tab
      fetchSavedKundlis(); // Refresh saved kundlis
      SnackbarUtil.success('Kundli generated successfully!');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
    isLoading.value = false;
  }

  Future<void> fetchSavedKundlis() async {
    final res = await _api.get(ApiConstants.savedKundlis);
    if (ApiService.isSuccess(res)) {
      savedKundlis.value = List.from(ApiService.getData(res) ?? []);
    }
  }
}
