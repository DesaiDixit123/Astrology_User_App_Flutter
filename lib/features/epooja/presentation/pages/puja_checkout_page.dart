import 'package:astrology_user/features/services/data/models/puja_model.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/snackbar_util.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';
import 'package:intl/intl.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/constants/app_constants.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PujaCheckoutPage extends StatefulWidget {
  final Puja puja;
  final PujaPackage package;
  final Map<String, dynamic> astrologer;
  final String mode;

  const PujaCheckoutPage({
    super.key,
    required this.puja,
    required this.package,
    required this.astrologer,
    required this.mode,
  });

  @override
  State<PujaCheckoutPage> createState() => _PujaCheckoutPageState();
}

class _PujaCheckoutPageState extends State<PujaCheckoutPage> {
  final pujaController = Get.find<PujaController>();
  final walletController = Get.put(WalletController());

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _houseController = TextEditingController();
  final TextEditingController _localityController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();
  final TextEditingController _pincodeController = TextEditingController();
  late Razorpay _razorpay;

  String _selectedCountry = 'India';
  String? _selectedState;
  String? _selectedCity;
  String _selectedPaymentMethod = 'wallet';

  @override
  void dispose() {
    _razorpay.clear();
    _dateController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _houseController.dispose();
    _localityController.dispose();
    _landmarkController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (response.paymentId != null && response.orderId != null && response.signature != null) {
      _finalizeBooking(
        razorpayOrderId: response.orderId,
        razorpayPaymentId: response.paymentId,
        razorpaySignature: response.signature,
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    SnackbarUtil.error('Payment Failed: ${response.message}');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    SnackbarUtil.info('External Wallet: ${response.walletName}');
  }

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    walletController.loadWalletData();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    bool isWide = MediaQuery.of(context).size.width > 900;

    return Scaffold(
      backgroundColor: const Color(0xFFFDF7F2),
      appBar: AppBar(
        title: Text('Checkout', style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: isWide
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 1, child: _leftColumn()),
                    SizedBox(width: 30.w),
                    Expanded(flex: 2, child: _rightColumn()),
                  ],
                )
              : Column(
                  children: [
                    _leftColumn(),
                    SizedBox(height: 20.h),
                    _rightColumn(),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _leftColumn() {
    return Column(
      children: [
        _buildOrderSummary(),
        SizedBox(height: 20.h),
        _buildPaymentMethods(),
      ],
    );
  }

  Widget _rightColumn() {
    return Column(
      children: [
        _buildShippingDetails(),
        SizedBox(height: 30.h),
        _buildConfirmButton(),
        SizedBox(height: 20.h),
        Text(
          'SECURED BY RAZORPAY • SSL ENCRYPTED',
          style: AppTextStyles.caption.copyWith(color: Colors.grey, letterSpacing: 1.2),
        ),
      ],
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 15.h),
            decoration: BoxDecoration(
              color: const Color(0xFFEFFFFA),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
            ),
            child: Center(
              child: Text(
                'ORDER SUMMARY',
                style: AppTextStyles.bodySmall.copyWith(color: const Color(0xFF10B981), fontWeight: FontWeight.w900, letterSpacing: 1.5),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(15.r),
                      child: Image.network(
                        widget.puja.fullImageUrl,
                        width: 70.w,
                        height: 70.w,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[100], child: const Icon(Icons.temple_hindu)),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.puja.title, style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF1E2633))),
                          Text('₹${widget.package.priceInr}', style: AppTextStyles.h4.copyWith(color: const Color(0xFF92400E))),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 25.h),
                _summaryRow('Order Value:', '₹${widget.package.priceInr}'),
                SizedBox(height: 12.h),
                _summaryRow('Shipping:', 'FREE', isFree: true),
                const Divider(height: 40, thickness: 1, color: Color(0xFFF1F5F9)),
                _summaryRow('NET PAYABLE:', '₹${widget.package.priceInr}', isTotal: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isFree = false, bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMedium.copyWith(color: isTotal ? const Color(0xFF1E2633) : const Color(0xFF64748B), fontWeight: isTotal ? FontWeight.w900 : FontWeight.bold)),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: isTotal ? const Color(0xFF1E2633) : (isFree ? const Color(0xFF10B981) : const Color(0xFF1E2633)),
            fontWeight: FontWeight.w900,
            fontSize: isTotal ? 20.sp : 16.sp,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PAYMENT METHOD', style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF64748B), letterSpacing: 1)),
        SizedBox(height: 15.h),
        Obx(() => _paymentTile(
              'wallet',
              'WALLET',
              '₹${walletController.balance.value} AVAIL.',
            )),
        SizedBox(height: 12.h),
        _paymentTile('online', 'RAZORPAY', null),
        if (widget.mode != 'online') ...[
          SizedBox(height: 12.h),
          _paymentTile('cod', 'CASH ON DELIVERY', null),
        ],
      ],
    );
  }

  Widget _paymentTile(String value, String title, String? subtitle) {
    bool isSelected = _selectedPaymentMethod == value;
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = value),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15.r),
          border: Border.all(color: isSelected ? const Color(0xFF451A03) : Colors.transparent, width: 2),
          boxShadow: [if (!isSelected) BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Icon(isSelected ? Icons.radio_button_checked : Icons.radio_button_off, color: isSelected ? const Color(0xFF451A03) : const Color(0xFFCBD5E1)),
            SizedBox(width: 15.w),
            Text(title, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF1E2633))),
            if (subtitle != null) ...[
              const Spacer(),
              Text(subtitle, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF451A03))),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildShippingDetails() {
    return Container(
      padding: EdgeInsets.all(30.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 25, offset: const Offset(0, 15))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.location_on, color: const Color(0xFF451A03), size: 28.sp),
              SizedBox(width: 12.w),
              Text('SHIPPING DETAILS', style: AppTextStyles.h4.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF1E2633))),
              const Spacer(),
              Icon(Icons.check_circle_outline, color: const Color(0xFFE2E8F0), size: 24.sp),
            ],
          ),
          SizedBox(height: 30.h),
          _rowFields([
            _buildField('PUJA DATE *', _dateController, Icons.calendar_today, readOnly: true, onTap: _selectDate),
            _buildField('NAME *', _nameController, Icons.person_outline),
          ]),
          _rowFields([
            _buildField('PHONE NO *', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
            _buildField('FLAT NO / HOUSE NO *', _houseController, null, hint: 'Enter Flat/House Details'),
          ]),
          _rowFields([
            _buildField('LOCALITY *', _localityController, null, hint: 'Street or Area Name'),
            _buildField('LANDMARK *', _landmarkController, null, hint: 'Nearby Landmark'),
          ]),
          _rowFields([
            _dropdownField('COUNTRY *', ['India'], _selectedCountry, (val) => setState(() => _selectedCountry = val!), icon: Icons.public),
            _dropdownField('STATE *', ['Gujarat', 'Maharashtra', 'Delhi'], _selectedState, (val) => setState(() => _selectedState = val!), hint: 'Select State'),
          ]),
          _rowFields([
            _dropdownField('CITY *', ['Ahmedabad', 'Surat', 'Mumbai'], _selectedCity, (val) => setState(() => _selectedCity = val!), hint: 'Select City'),
            _buildField('PINCODE *', _pincodeController, null, keyboardType: TextInputType.number, hint: '6-digit Pincode'),
          ]),
        ],
      ),
    );
  }

  Widget _rowFields(List<Widget> children) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: children[0]),
          SizedBox(width: 20.w),
          Expanded(child: children[1]),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, IconData? icon, {bool readOnly = false, VoidCallback? onTap, TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF64748B), fontSize: 11.sp, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          onTap: onTap,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp),
            prefixIcon: icon != null ? Icon(icon, size: 20.sp, color: const Color(0xFFCBD5E1)) : null,
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
          ),
          validator: (val) => val == null || val.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Widget _dropdownField(String label, List<String> items, String? value, Function(String?) onChanged, {String? hint, IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF64748B), fontSize: 11.sp, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(12.r)),
          child: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 20.sp, color: const Color(0xFFCBD5E1)), SizedBox(width: 10.w)],
              Expanded(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: value,
                    hint: Text(hint ?? 'Select', style: TextStyle(color: const Color(0xFF94A3B8), fontSize: 13.sp)),
                    items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)))).toList(),
                    onChanged: onChanged,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFFCBD5E1)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _handleBooking,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF451A03),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
          padding: EdgeInsets.symmetric(vertical: 20.h),
          elevation: 8,
          shadowColor: const Color(0xFF451A03).withOpacity(0.4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('CONFIRM PUJA BOOKING', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16.sp, letterSpacing: 1.2)),
            SizedBox(width: 15.w),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _dateController.text = DateFormat('dd/MM/yyyy').format(picked));
    }
  }

  Future<void> _handleBooking() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedState == null || _selectedCity == null) {
      SnackbarUtil.error('Please select state and city');
      return;
    }

    final shippingDetails = {
      'name': _nameController.text,
      'phone_no': _phoneController.text,
      'flat_house_no': _houseController.text,
      'locality': _localityController.text,
      'landmark': _landmarkController.text,
      'country': _selectedCountry,
      'state': _selectedState,
      'city': _selectedCity,
      'pincode': _pincodeController.text,
    };

    final request = PujaOrderRequest(
      pujaId: widget.puja.id,
      packageId: widget.package.id,
      astrologerId: widget.astrologer['_id'],
      bookingDate: _dateController.text,
      mode: widget.mode,
      paymentMethod: _selectedPaymentMethod,
      shippingDetails: shippingDetails,
    );

    if (_selectedPaymentMethod == 'online') {
      _startRazorpayPayment(widget.package.id);
    } else {
      final success = await pujaController.bookPuja(request);
      if (success) {
        Get.offNamed(AppRoutes.pujaHistory);
        SnackbarUtil.success('Booking Confirmed!');
      }
    }
  }

  Future<void> _startRazorpayPayment(String packageId) async {
    final paymentData = await pujaController.createPujaPayment(packageId);
    if (paymentData != null) {
      var options = {
        'key': AppConstants.razorpayKeyId,
        'amount': paymentData['amount'],
        'name': 'Puja Booking',
        'order_id': paymentData['id'],
        'description': widget.puja.title,
        'prefill': {
          'contact': _phoneController.text,
          'email': '', 
        },
        'external': {
          'wallets': ['paytm']
        }
      };

      try {
        _razorpay.open(options);
      } catch (e) {
        SnackbarUtil.error('Failed to open payment gateway');
      }
    }
  }

  Future<void> _finalizeBooking({
    String? razorpayOrderId,
    String? razorpayPaymentId,
    String? razorpaySignature,
  }) async {
    final shippingDetails = {
      'name': _nameController.text,
      'phone': _phoneController.text,
      'flat_no': _houseController.text,
      'locality': _localityController.text,
      'landmark': _landmarkController.text,
      'country': _selectedCountry,
      'state': _selectedState ?? '',
      'city': _selectedCity ?? '',
      'pincode': _pincodeController.text,
    };

    final request = PujaOrderRequest(
      pujaId: widget.puja.id,
      packageId: widget.package.id,
      astrologerId: widget.astrologer['_id'],
      bookingDate: _dateController.text,
      mode: widget.mode,
      paymentMethod: _selectedPaymentMethod,
      shippingDetails: shippingDetails,
      razorpayOrderId: razorpayOrderId,
      razorpayPaymentId: razorpayPaymentId,
      razorpaySignature: razorpaySignature,
    );

    final success = await pujaController.bookPuja(request);
    if (success) {
      Get.offNamed(AppRoutes.pujaHistory);
      SnackbarUtil.success('Booking Confirmed!');
    }
  }
}
