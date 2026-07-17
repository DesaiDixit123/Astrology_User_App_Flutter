import 'package:astrology_user/config/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../../core/services/notification_service.dart';

class AuthController extends GetxController {
  final phoneController = TextEditingController();
  final List<TextEditingController> otpControllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> otpFocusNodes =
      List.generate(6, (index) => FocusNode());
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final dobController = TextEditingController();

  final RxBool isLoading = false.obs;
  final RxString phoneNumber = ''.obs;
  final RxString serverOtp = ''.obs;
  final RxString selectedGender = ''.obs;
  final Rx<File?> selectedImage = Rx<File?>(null);
  final ImagePicker _picker = ImagePicker();

  final _api = ApiService.instance;

  @override
  void onClose() {
    phoneController.dispose();
    for (var c in otpControllers) c.dispose();
    for (var n in otpFocusNodes) n.dispose();
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    super.onClose();
  }

  Future<void> sendOTP({bool navigateToOtp = true}) async {
    if (phoneController.text.isEmpty || phoneController.text.length < 10) {
      SnackbarUtil.error('Please enter a valid phone number');
      return;
    }
    isLoading.value = true;
    final res = await _api.post(ApiConstants.sendOtp, data: {
      'mobile': phoneController.text.trim(),
      'country_code': '+91',
    });
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      phoneNumber.value = phoneController.text.trim();
      serverOtp.value = data?['otp']?.toString() ?? '';
      _clearOtpInputs();
      SnackbarUtil.success(ApiService.getMessage(res));
      if (navigateToOtp) {
        Get.toNamed(AppRoutes.otp);
      }
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> verifyOTP() async {
    _unfocusOtpInputs();
    final otp = otpControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      SnackbarUtil.error('Please enter a valid 6-digit OTP');
      return;
    }
    isLoading.value = true;
    final res = await _api.post(ApiConstants.verifyOtp, data: {
      'mobile': phoneNumber.value,
      'otp': otp,
      'country_code': '+91',
    });
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        final customer = (data['customer'] as Map?)?.cast<String, dynamic>() ?? {};
        await prefs.setString(AppConstants.keyToken, data['accessToken'] ?? '');
        await prefs.setString(
          AppConstants.keyUserId,
          customer['_id']?.toString() ?? '',
        );
        await prefs.setString(
          AppConstants.keyUserName,
          customer['name']?.toString() ?? '',
        );
        await prefs.setString(
          AppConstants.keyUserEmail,
          customer['email']?.toString() ?? '',
        );
        await prefs.setString(
          AppConstants.keyUserPhone,
          customer['mobile']?.toString() ?? phoneNumber.value,
        );
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);

        final isNewUser = data['is_new_user'] == true;
        await prefs.setBool(AppConstants.keyProfileComplete, !isNewUser);
        if (isNewUser) {
          Get.offAllNamed(AppRoutes.register);
        } else {
          _resetAuthState();
          Get.offAllNamed(AppRoutes.dashboard);
          NotificationService().syncToken(); // Sync FCM token
          _deleteSelf();
        }
      }
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
  }

  Future<void> register() async {
    if (nameController.text.isEmpty) {
      SnackbarUtil.error('Please enter your name');
      return;
    }
    isLoading.value = true;
    
    final formDataMap = <String, dynamic>{
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'dob': dobController.text.trim(),
      'gender': selectedGender.value.toLowerCase(),
      'mobile': phoneNumber.value,
    };

    if (selectedImage.value != null) {
      try {
        formDataMap['profile_pic'] = await dio.MultipartFile.fromFile(
          selectedImage.value!.path,
        );
      } catch (e) {
        debugPrint('Error attaching file: $e');
      }
    }

    final formData = dio.FormData.fromMap(formDataMap);

    final res = await _api.post(ApiConstants.register, data: formData);
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      if (data != null) {
        final prefs = await SharedPreferences.getInstance();
        if (data.containsKey('accessToken')) {
          await prefs.setString(AppConstants.keyToken, data['accessToken']);
        }
        if (data.containsKey('customer') && data['customer']?['_id'] != null) {
          await prefs.setString(AppConstants.keyUserId, data['customer']['_id'].toString());
        }
        await prefs.setString(
          AppConstants.keyUserName,
          data['customer']?['name']?.toString() ?? nameController.text.trim(),
        );
        await prefs.setString(
          AppConstants.keyUserEmail,
          data['customer']?['email']?.toString() ?? emailController.text.trim(),
        );
        await prefs.setString(
          AppConstants.keyUserPhone,
          data['customer']?['mobile']?.toString() ?? phoneNumber.value,
        );
        await prefs.setBool(AppConstants.keyIsLoggedIn, true);
        await prefs.setBool(AppConstants.keyProfileComplete, true);
      }
      _resetAuthState();
      Get.offAllNamed(AppRoutes.dashboard);
      NotificationService().syncToken(); // Sync FCM token
      _deleteSelf();
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
    }
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

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      if (image != null) {
        selectedImage.value = File(image.path);
      }
    } catch (e) {
      SnackbarUtil.error('Failed to pick image');
    }
  }

  void _clearOtpInputs() {
    for (final controller in otpControllers) {
      controller.clear();
    }
  }

  void _unfocusOtpInputs() {
    for (final node in otpFocusNodes) {
      if (node.hasFocus) {
        node.unfocus();
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
  }

  void _resetAuthState() {
    phoneController.clear();
    phoneNumber.value = '';
    serverOtp.value = '';
    _clearOtpInputs();
    nameController.clear();
    emailController.clear();
    dobController.clear();
    selectedGender.value = '';
  }

  void _deleteSelf() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (Get.isRegistered<AuthController>()) {
        Get.delete<AuthController>(force: true);
      }
    });
  }
}
