import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/localization/app_language_controller.dart';
import 'package:geolocator/geolocator.dart';

class ServiceController extends GetxController {
  final RxList categories = [].obs;
  final RxList services = [].obs;
  final RxList astrologersByService = [].obs;
  final RxList myOrders = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isBooking = false.obs;
  final RxBool isHoroscopeSignsLoading = false.obs;
  final RxBool isHoroscopeDetailLoading = false.obs;

  // ── Horoscope & Panchang ────────────
  final RxList horoscopeSigns = [].obs;
  final RxMap horoscopeResult = {}.obs;
  final RxMap panchangResult = {}.obs;

  final _api = ApiService.instance;
  String _loadedHoroscopeLanguage = '';

  Future<bool> getHoroscope(String sign, {String type = 'daily'}) async {
    final lang = Get.find<AppLanguageController>().currentLanguageCode;
    isHoroscopeDetailLoading.value = true;
    final encodedSign = Uri.encodeComponent(sign);
    final res = await _api.get(
      '${ApiConstants.horoscopeSigns}/$encodedSign/$lang',
      queryParameters: {'type': type},
    );
    isHoroscopeDetailLoading.value = false;
    if (ApiService.isSuccess(res)) {
      horoscopeResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      horoscopeResult.clear();
      return false;
    }
  }

  Future<void> loadHoroscopeSigns() async {
    final lang = Get.find<AppLanguageController>().currentLanguageCode;
    isHoroscopeSignsLoading.value = true;
    final localizedRes = await _api.get(
      '${ApiConstants.horoscopeSigns}/list/$lang',
    );
    final englishRes = lang == 'en'
        ? localizedRes
        : await _api.get('${ApiConstants.horoscopeSigns}/list/en');
    isHoroscopeSignsLoading.value = false;

    if (ApiService.isSuccess(localizedRes) &&
        ApiService.isSuccess(englishRes)) {
      _loadedHoroscopeLanguage = lang;
      final localizedSigns = List<Map<String, dynamic>>.from(
        (ApiService.getData(localizedRes) as List? ?? const []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      final englishSigns = List<Map<String, dynamic>>.from(
        (ApiService.getData(englishRes) as List? ?? const []).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      final englishById = {
        for (final sign in englishSigns)
          sign['_id']?.toString() ?? '': sign['sign_name']?.toString() ?? '',
      };

      horoscopeSigns.value = localizedSigns.map((sign) {
        final enriched = Map<String, dynamic>.from(sign);
        final signId = sign['_id']?.toString() ?? '';
        enriched['canonical_name'] =
            englishById[signId]?.trim().isNotEmpty == true
            ? englishById[signId]
            : sign['sign_name']?.toString() ?? '';
        return enriched;
      }).toList();
    } else {
      horoscopeSigns.clear();
      final failedRes = ApiService.isSuccess(localizedRes)
          ? englishRes
          : localizedRes;
      SnackbarUtil.error(ApiService.getMessage(failedRes));
    }
  }

  void ensureHoroscopeSignsLoaded() {
    final lang = Get.find<AppLanguageController>().currentLanguageCode;
    if (isHoroscopeSignsLoading.value) return;
    if (horoscopeSigns.isEmpty || _loadedHoroscopeLanguage != lang) {
      loadHoroscopeSigns();
    }
  }

  // Helper to get real device location (fallback to default if permission denied)
  Future<Map<String, String>> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // Test if location services are enabled.
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {'lat': '28.6139', 'lon': '77.2090'};
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {'lat': '28.6139', 'lon': '77.2090'};
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {'lat': '28.6139', 'lon': '77.2090'};
      }

      // When we reach here, permissions are granted and we can
      // continue accessing the position of the device.
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return {
        'lat': position.latitude.toStringAsFixed(4),
        'lon': position.longitude.toStringAsFixed(4),
      };
    } catch (e) {
      // Fallback to Delhi coordinates
      return {'lat': '28.6139', 'lon': '77.2090'};
    }
  }

  Future<void> getPanchang([String? date]) async {
    final loc = await _getCurrentLocation();
    isLoading.value = true;
    final query = date != null ? '?date=$date' : '';
    final res = await _api.get(
      '/customer/panchang$query',
      queryParameters: {'lat': loc['lat']!, 'lon': loc['lon']!},
    );
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchangResult.value = Map<String, dynamic>.from(
        ApiService.getData(res)?['response'] ?? ApiService.getData(res) ?? {},
      );
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      panchangResult.clear();
    }
  }

  Future<void> getTodayPanchang({String language = 'en'}) async {
    final loc = await _getCurrentLocation();
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangToday}/$language';
    final res = await _api.get(
      endpoint,
      queryParameters: {'lat': loc['lat']!, 'lon': loc['lon']!, 'tz': '5.5'},
    );
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchangResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getTomorrowPanchang({String language = 'en'}) async {
    final loc = await _getCurrentLocation();
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangTomorrow}/$language';
    final res = await _api.get(
      endpoint,
      queryParameters: {'lat': loc['lat']!, 'lon': loc['lon']!, 'tz': '5.5'},
    );
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchangResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getPanchangByDate({
    required String date,
    String language = 'en',
  }) async {
    final loc = await _getCurrentLocation();
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangByDate}/$language';
    final res = await _api.get(
      endpoint,
      queryParameters: {
        'date': date,
        'lat': loc['lat']!,
        'lon': loc['lon']!,
        'tz': '5.5',
      },
    );
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchangResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getBriefPanchang({String language = 'en'}) async {
    final loc = await _getCurrentLocation();
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangBrief}/$language';
    final res = await _api.get(
      endpoint,
      queryParameters: {'lat': loc['lat']!, 'lon': loc['lon']!, 'tz': '5.5'},
    );
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchangResult.value = Map<String, dynamic>.from(
        ApiService.getData(res) ?? {},
      );
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadCategories();
    loadHoroscopeSigns();
  }

  Future<void> loadCategories() async {
    isLoading.value = true;
    final res = await _api.get(ApiConstants.serviceCategories);
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      categories.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> loadServicesByCategory(String categoryId) async {
    isLoading.value = true;
    final res = await _api.get('/customer/services/$categoryId');
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      services.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<void> loadAstrologersByService(String serviceId) async {
    isLoading.value = true;
    final res = await _api.get('/customer/service/$serviceId/astrologers');
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      astrologersByService.value = List.from(ApiService.getData(res) ?? []);
    }
  }

  Future<bool> bookService({
    required String astrologerServiceId,
    required String bookingDate,
    required String bookingTime,
    String notes = '',
  }) async {
    isBooking.value = true;
    final res = await _api.post(
      ApiConstants.bookService,
      data: {
        'astrologer_service_id': astrologerServiceId,
        'booking_date': bookingDate,
        'booking_time': bookingTime,
        'notes': notes,
      },
    );
    isBooking.value = false;
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success(
        'Service booked! Waiting for astrologer acceptance.',
      );
      await loadMyOrders();
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return false;
    }
  }

  Future<void> loadMyOrders() async {
    final res = await _api.get(
      ApiConstants.myServiceOrders,
      queryParameters: {'page': 1, 'limit': 20},
    );
    if (ApiService.isSuccess(res)) {
      myOrders.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
  }
}
