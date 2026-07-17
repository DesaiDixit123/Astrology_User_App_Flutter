import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/localization/app_language_controller.dart';

class PredictionController extends GetxController {
  final RxMap horoscope = {}.obs;
  final RxMap panchang = {}.obs;
  final RxMap kundli = {}.obs;
  final RxMap kundliMatch = {}.obs;
  final RxMap numerology = {}.obs;
  final RxBool isLoading = false.obs;

  final _api = ApiService.instance;

  Future<void> getHoroscope({required String sign, String type = 'daily'}) async {
    isLoading.value = true;
    final lang = Get.find<AppLanguageController>().currentLanguageCode;
    final res = await _api.post(ApiConstants.horoscope, data: {'sign': sign, 'type': type, 'lang': lang});
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      horoscope.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getPanchang({String? date, String lat = '28.6139', String lon = '77.2090'}) async {
    // Existing generic Panchang endpoint (kept for backward compatibility)
    isLoading.value = true;
    final res = await _api.get(ApiConstants.panchang, queryParameters: {
      if (date != null) 'date': date,
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchang.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  // New specific Panchang endpoints
  Future<void> getTodayPanchang({String language = 'en', String lat = '28.6139', String lon = '77.2090'}) async {
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangToday}/$language';
    final res = await _api.get(endpoint, queryParameters: {
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchang.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getTomorrowPanchang({String language = 'en', String lat = '28.6139', String lon = '77.2090'}) async {
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangTomorrow}/$language';
    final res = await _api.get(endpoint, queryParameters: {
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchang.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getPanchangByDate({required String date, String language = 'en', String lat = '28.6139', String lon = '77.2090'}) async {
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangByDate}/$language';
    final res = await _api.get(endpoint, queryParameters: {
      'date': date,
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchang.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getBriefPanchang({String language = 'en', String lat = '28.6139', String lon = '77.2090'}) async {
    isLoading.value = true;
    final endpoint = '${ApiConstants.panchangBrief}/$language';
    final res = await _api.get(endpoint, queryParameters: {
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      panchang.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }


  Future<void> getKundli({
    required String dob,
    required String tob,
    required String lat,
    required String lon,
  }) async {
    isLoading.value = true;
    final res = await _api.post(ApiConstants.kundli, data: {
      'dob': dob,
      'tob': tob,
      'lat': lat,
      'lon': lon,
      'tz': '5.5',
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      kundli.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getKundliMatch({
    required String boyDob, required String boyTob, required String boyLat, required String boyLon,
    required String girlDob, required String girlTob, required String girlLat, required String girlLon,
  }) async {
    isLoading.value = true;
    final res = await _api.post(ApiConstants.kundliMatch, data: {
      'boy_dob': boyDob, 'boy_tob': boyTob, 'boy_lat': boyLat, 'boy_lon': boyLon,
      'girl_dob': girlDob, 'girl_tob': girlTob, 'girl_lat': girlLat, 'girl_lon': girlLon,
    });
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      kundliMatch.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> getNumerology({required String name, required String dob}) async {
    isLoading.value = true;
    final res = await _api.post(ApiConstants.numerology, data: {'name': name, 'dob': dob});
    isLoading.value = false;
    if (ApiService.isSuccess(res)) {
      numerology.value = Map<String, dynamic>.from(ApiService.getData(res) ?? {});
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }
}
