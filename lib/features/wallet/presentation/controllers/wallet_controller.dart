import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/snackbar_util.dart';

class WalletController extends GetxController {
  final RxDouble walletBalance = 0.0.obs;
  final RxList transactions = [].obs;
  final RxList rechargeOptions = [].obs;
  final RxInt gstPercent = 18.obs;
  final RxBool isLoading = false.obs;
  final RxBool isRecharging = false.obs;

  late Razorpay _razorpay;
  String _userEmail = '';
  String _userPhone = '';
  double _lastAttemptedAmount = 0;

  // ── Backward-compatible aliases for existing pages ───────
  RxDouble get balance => walletBalance;

  final _api = ApiService.instance;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    loadWalletData();
    _loadUserInfo();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString(AppConstants.keyUserEmail) ?? '';
    _userPhone = prefs.getString(AppConstants.keyUserPhone) ?? '';
  }

  Future<void> loadWalletData() async {
    isLoading.value = true;
    await Future.wait([
      _fetchBalance(),
      _fetchTransactions(),
      _fetchRechargeOptions(),
    ]);
    isLoading.value = false;
  }

  Future<void> _fetchBalance() async {
    final res = await _api.get(ApiConstants.walletBalance);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      walletBalance.value = (data?['wallet_balance'] ?? 0).toDouble();
    }
  }

  Future<void> _fetchTransactions({int page = 1}) async {
    final res = await _api.get(
      ApiConstants.walletTransactions,
      queryParameters: {'page': page, 'limit': 20},
    );
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      transactions.value = List.from(data?['docs'] ?? []);
    }
  }

  Future<void> _fetchRechargeOptions() async {
    final res = await _api.get(ApiConstants.rechargeOptions);
    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res);
      if (data is Map<String, dynamic>) {
        rechargeOptions.value = List.from(data['recharge_cards'] ?? []);
        gstPercent.value = data['gst_percent'] ?? 18;
      } else {
        rechargeOptions.value = List.from(data ?? []);
      }
    }
  }

  /// Entry point for UI to start recharge
  Future<void> rechargeWallet({
    required double amount,
    required double totalAmount,
  }) async {
    _lastAttemptedAmount = amount;
    final orderData = await createRechargeOrder(totalAmount);
    if (orderData != null) {
      _openRazorpay(orderData);
    }
  }

  /// Creates a Razorpay order and returns {order_id, amount, currency, key}
  Future<Map<String, dynamic>?> createRechargeOrder(double amount) async {
    isRecharging.value = true;
    final res = await _api.post(
      ApiConstants.createRechargeOrder,
      data: {'amount': amount},
    );
    isRecharging.value = false;
    if (ApiService.isSuccess(res)) {
      return ApiService.getData(res) as Map<String, dynamic>?;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return null;
    }
  }

  void _openRazorpay(Map<String, dynamic> orderData) {
    final keyId = orderData['key']?.toString() ?? orderData['key_id']?.toString() ?? AppConstants.razorpayKeyId;
    final orderId = orderData['order_id']?.toString() ?? '';

    final Map<String, dynamic> options = {
      'key': keyId,
      'amount': orderData['amount'],
      'name': 'Vedikvani User',
      'description': 'Wallet Recharge',
      'prefill': {
        'contact': _userPhone.isNotEmpty ? _userPhone : '9904755099',
        'email': _userEmail.isNotEmpty ? _userEmail : 'admin@thekhushiempire.com',
      },
      'theme': {'color': '#E65100'},
      'retry': {'enabled': true, 'max_count': 1},
      'send_sms_hash': true,
    };

    if (orderId.isNotEmpty && !orderId.startsWith('order_sim_')) {
      options['order_id'] = orderId;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error: $e');
      SnackbarUtil.error('Could not open payment gateway: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    if (response.orderId != null &&
        response.paymentId != null &&
        response.signature != null) {
      verifyRecharge(
        orderId: response.orderId!,
        paymentId: response.paymentId!,
        signature: response.signature!,
        amount: _lastAttemptedAmount,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    SnackbarUtil.error(response.message ?? 'Payment failed');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    SnackbarUtil.info('External wallet selected: ${response.walletName}');
  }

  /// Call this after Razorpay payment succeeds
  Future<bool> verifyRecharge({
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
    double bonus = 0,
  }) async {
    isLoading.value = true;
    final res = await _api.post(
      ApiConstants.verifyRecharge,
      data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        'amount': amount,
        'bonus': bonus,
      },
    );
    isLoading.value = false;

    if (ApiService.isSuccess(res)) {
      final data = ApiService.getData(res) as Map<String, dynamic>?;
      walletBalance.value = (data?['wallet_balance'] ?? walletBalance.value)
          .toDouble();
      SnackbarUtil.success('Wallet recharged successfully!');
      await _fetchTransactions();
      return true;
    } else {
      SnackbarUtil.error(ApiService.getMessage(res));
      return false;
    }
  }

  @override
  Future<void> refresh() => loadWalletData();
}
