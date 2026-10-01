import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class ProfileController extends GetxController {
  final RxMap profile = {}.obs;
  final RxList orders = [].obs;
  final RxList serviceOrders = [].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // ── Backward-compatible aliases for existing pages ───────
  RxMap get userData => profile;
  RxString selectedAvatarUrl = ''.obs;
  RxList avatars = [].obs;
  void selectAvatar(String url) => selectedAvatarUrl.value = url;

  // Edit controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final dobController = TextEditingController();
  final birthTimeController = TextEditingController();
  final birthPlaceController = TextEditingController();
  final occupationController = TextEditingController();
  final RxString selectedGender = ''.obs;
  final RxString selectedMaritalStatus = ''.obs;
  final Rx<File?> imageFile = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    _loadCachedProfile();
    loadProfile();
  }

  Future<void> _loadCachedProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedName = prefs.getString(AppConstants.keyUserName) ?? '';
      final cachedPhone = prefs.getString(AppConstants.keyUserPhone) ?? '';
      final cachedEmail = prefs.getString(AppConstants.keyUserEmail) ?? '';
      if (cachedName.isNotEmpty && (profile['name'] == null || profile['name'].toString().isEmpty)) {
        profile['name'] = cachedName;
        nameController.text = cachedName;
      }
      if (cachedPhone.isNotEmpty && phoneController.text.isEmpty) {
        phoneController.text = cachedPhone;
      }
      if (cachedEmail.isNotEmpty && emailController.text.isEmpty) {
        emailController.text = cachedEmail;
      }
    } catch (_) {}
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    birthTimeController.dispose();
    birthPlaceController.dispose();
    occupationController.dispose();
    super.onClose();
  }

  Future<void> loadProfile() async {
    isLoading.value = true;
    await Future.wait([_fetchProfile(), _fetchOrders()]);
    if (Get.isRegistered<WalletController>()) {
      Get.find<WalletController>().refresh();
    }
    isLoading.value = false;
  }

  Future<void> refreshOrders() async {
    isLoading.value = true;
    await _fetchOrders();
    isLoading.value = false;
  }

  Future<void> _fetchProfile() async {
    final res = await _api.get(ApiConstants.profile);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        profile.value = data;
        nameController.text = data['name'] ?? '';
        emailController.text = data['email'] ?? '';
        final mobile = (data['mobile'] ?? '').toString();
        final countryCode = (data['country_code'] ?? '').toString();
        phoneController.text = mobile.isEmpty ? '' : '$countryCode $mobile'.trim();
        dobController.text = data['dob'] ?? '';
        birthTimeController.text = data['birth_time'] ?? '';
        birthPlaceController.text = data['place_of_birth'] ?? '';
        occupationController.text = data['occupation'] ?? '';
        selectedGender.value = data['gender'] ?? '';
        selectedMaritalStatus.value = data['marital_status'] ?? '';
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.keyUserName, nameController.text);
        await prefs.setString(AppConstants.keyUserEmail, emailController.text);
        await prefs.setString(AppConstants.keyUserPhone, (data['mobile'] ?? '').toString());
      }
    }
  }

  String get profileImageUrl {
    final value = profile['profile_pic'] ?? profile['profilePic'] ?? '';
    return ApiConstants.resolveImage(value.toString());
  }

  Future<void> _fetchOrders() async {
    final res = await _api.get(ApiConstants.orders, queryParameters: {'page': 1, 'limit': 20});
    if (ApiService.isSuccess(res)) {
      orders.value = List.from(ApiService.getData(res)?['docs'] ?? []);
    }
    final sRes = await _api.get(ApiConstants.myServiceOrders, queryParameters: {'page': 1, 'limit': 20});
    if (ApiService.isSuccess(sRes)) {
      serviceOrders.value = List.from(ApiService.getData(sRes)?['docs'] ?? []);
    }
  }

  Future<void> updateProfile() async {
    if (nameController.text.trim().isEmpty) {
      SnackbarUtil.error('Name is required');
      return;
    }
    isSaving.value = true;
    try {
      final genderVal = selectedGender.value.trim();
      final maritalVal = selectedMaritalStatus.value.trim();

      final Map<String, dynamic> data = {
        'name': nameController.text.trim(),
        'email': emailController.text.trim(),
        'dob': dobController.text.trim(),
        'gender': (genderVal.toLowerCase() == 'select' || genderVal.toLowerCase() == 'none') ? '' : genderVal,
        'birth_time': birthTimeController.text.trim(),
        'place_of_birth': birthPlaceController.text.trim(),
        'marital_status': (maritalVal.toLowerCase() == 'select' || maritalVal.toLowerCase() == 'none') ? '' : maritalVal,
        'occupation': occupationController.text.trim(),
      };

      dynamic finalData;
      if (imageFile.value != null) {
        finalData = dio.FormData.fromMap({
          ...data,
          'profile_pic': await dio.MultipartFile.fromFile(imageFile.value!.path),
        });
      } else {
        finalData = data;
      }

      final res = await _api.put(ApiConstants.profile, data: finalData);
      if (ApiService.isSuccess(res)) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(AppConstants.keyProfileComplete, true);
        await prefs.setString(AppConstants.keyUserName, nameController.text.trim());
        await prefs.setString(AppConstants.keyUserEmail, emailController.text.trim());
        await prefs.setString(AppConstants.keyUserPhone, profile['mobile']?.toString() ?? '');
        SnackbarUtil.success('Profile updated successfully!');
        imageFile.value = null;
        await _fetchProfile();
        Get.back();
      } else {
        SnackbarUtil.error(ApiService.getMessage(res));
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');
      SnackbarUtil.error('Failed to update profile: $e');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> submitReview({
    required String astrologerId,
    required int rating,
    String comment = '',
    String? sessionId,
  }) async {
    final res = await _api.post(ApiConstants.submitReview, data: {
      'astrologer_id': astrologerId,
      'rating': rating,
      'comment': comment,
      'session_id': sessionId,
    });
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Review submitted. Thank you!');
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> deleteAccount() async {
    isSaving.value = true;
    final res = await _api.delete(ApiConstants.profile);
    isSaving.value = false;
    if (ApiService.isSuccess(res)) {
      SnackbarUtil.success('Account deleted successfully.');
      await logout();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, false);
    await prefs.setBool(AppConstants.keyProfileComplete, false);
    await prefs.remove(AppConstants.keyToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserData);

    // Clean up all controllers and socket listeners cleanly
    Get.deleteAll(force: true);

    Get.offAllNamed(AppRoutes.login);
  }

  void setGender(String gender) => selectedGender.value = gender;

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  Future<void> selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      final hour = picked.hourOfPeriod == 0 ? 12 : picked.hourOfPeriod;
      final minute = picked.minute.toString().padLeft(2, '0');
      final period = picked.period == DayPeriod.am ? 'AM' : 'PM';
      birthTimeController.text = '$hour:$minute $period';
    }
  }

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      imageFile.value = File(image.path);
    }
  }
}
