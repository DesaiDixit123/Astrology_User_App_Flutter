import 'package:astrology_user/features/services/data/models/puja_model.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/network/api_service.dart';
import '../../../../core/constants/api_constants.dart';
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
  String? _selectedState = 'Gujarat';
  String? _selectedCity = 'Surat';
  String _selectedPaymentMethod = 'wallet';

  final List<String> _countries = [
    'India',
    'United States',
    'United Kingdom',
    'Canada',
    'Australia',
    'United Arab Emirates',
    'Nepal',
    'Sri Lanka',
    'Singapore',
    'Germany',
  ];

  final Map<String, List<String>> _statesMap = {
    'India': [
      'Gujarat',
      'Maharashtra',
      'Rajasthan',
      'Delhi',
      'Uttar Pradesh',
      'Madhya Pradesh',
      'Karnataka',
      'Tamil Nadu',
      'West Bengal',
      'Punjab',
      'Haryana',
      'Bihar',
      'Telangana',
      'Kerala',
      'Andhra Pradesh',
      'Odisha',
      'Assam',
      'Goa',
      'Himachal Pradesh',
      'Jammu & Kashmir',
      'Jharkhand',
      'Chhattisgarh',
      'Uttarakhand',
    ],
    'United States': [
      'California',
      'Texas',
      'New York',
      'Florida',
      'Illinois',
      'Washington',
      'Georgia',
      'New Jersey',
      'Pennsylvania',
      'Ohio',
    ],
    'United Kingdom': [
      'England',
      'Scotland',
      'Wales',
      'Northern Ireland',
    ],
    'Canada': [
      'Ontario',
      'British Columbia',
      'Quebec',
      'Alberta',
      'Manitoba',
    ],
    'Australia': [
      'New South Wales',
      'Victoria',
      'Queensland',
      'Western Australia',
      'South Australia',
    ],
    'United Arab Emirates': [
      'Dubai',
      'Abu Dhabi',
      'Sharjah',
      'Ajman',
    ],
    'Nepal': [
      'Bagmati',
      'Gandaki',
      'Lumbini',
      'Koshi',
      'Madhesh',
    ],
    'Sri Lanka': [
      'Western',
      'Central',
      'Southern',
      'Northern',
    ],
    'Singapore': [
      'Central Region',
      'East Region',
      'North Region',
      'West Region',
    ],
    'Germany': [
      'Bavaria',
      'Berlin',
      'Hamburg',
      'Hesse',
      'Baden-Württemberg',
    ],
  };

  final Map<String, List<String>> _citiesMap = {
    'Gujarat': [
      'Surat',
      'Ahmedabad',
      'Vadodara',
      'Rajkot',
      'Bhavnagar',
      'Jamnagar',
      'Junagadh',
      'Gandhinagar',
      'Anand',
      'Navsari',
      'Valsad',
      'Bharuch',
      'Mehsana',
      'Bhuj',
      'Porbandar',
    ],
    'Maharashtra': [
      'Mumbai',
      'Pune',
      'Nagpur',
      'Thane',
      'Nashik',
      'Aurangabad',
      'Solapur',
      'Amravati',
      'Kolhapur',
      'Navi Mumbai',
      'Jalgaon',
    ],
    'Rajasthan': [
      'Jaipur',
      'Jodhpur',
      'Udaipur',
      'Kota',
      'Bikaner',
      'Ajmer',
      'Bhilwara',
      'Alwar',
    ],
    'Delhi': [
      'New Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi',
      'Central Delhi',
    ],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Varanasi',
      'Agra',
      'Noida',
      'Ghaziabad',
      'Prayagraj',
      'Meerut',
      'Bareilly',
      'Gorakhpur',
    ],
    'Madhya Pradesh': [
      'Bhopal',
      'Indore',
      'Gwalior',
      'Jabalpur',
      'Ujjain',
      'Sagar',
    ],
    'Karnataka': [
      'Bengaluru',
      'Mysuru',
      'Hubballi',
      'Mangaluru',
      'Belagavi',
      'Davanagere',
    ],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
      'Tiruppur',
    ],
    'West Bengal': [
      'Kolkata',
      'Howrah',
      'Durgapur',
      'Asansol',
      'Siliguri',
    ],
    'Punjab': [
      'Ludhiana',
      'Amritsar',
      'Jalandhar',
      'Patiala',
      'Bathinda',
      'Mohali',
    ],
    'Haryana': [
      'Gurugram',
      'Faridabad',
      'Panipat',
      'Ambala',
      'Karnal',
      'Hisar',
    ],
    'California': [
      'Los Angeles',
      'San Francisco',
      'San Diego',
      'San Jose',
      'Sacramento',
    ],
    'New York': [
      'New York City',
      'Buffalo',
      'Rochester',
      'Albany',
    ],
    'Texas': [
      'Houston',
      'Dallas',
      'Austin',
      'San Antonio',
    ],
    'Ontario': [
      'Toronto',
      'Ottawa',
      'Mississauga',
      'Hamilton',
    ],
    'England': [
      'London',
      'Manchester',
      'Birmingham',
      'Liverpool',
      'Leeds',
    ],
    'Dubai': [
      'Dubai City',
      'Jumeirah',
      'Deira',
      'Bur Dubai',
    ],
    'Abu Dhabi': [
      'Abu Dhabi City',
      'Al Ain',
    ],
  };

  String _getAstrologerId() {
    final String? id = widget.astrologer['_id']?.toString() ??
        widget.astrologer['id']?.toString() ??
        widget.astrologer['astrologer_id']?.toString() ??
        widget.astrologer['astrologerId']?.toString();
    if (id != null && id.isNotEmpty) return id;
    return '65c81f72e34f8a1234567890';
  }

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

  List<Map<String, dynamic>> _apiCountries = [];
  List<Map<String, dynamic>> _apiStates = [];
  List<Map<String, dynamic>> _apiCities = [];

  String? _selectedCountryCode = 'IN';
  String? _selectedStateCode = 'GJ';

  Future<void> _fetchLocationCountries() async {
    try {
      final response = await ApiService.instance.get(ApiConstants.locationCountries);
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        if (data.isNotEmpty) {
          if (mounted) {
            setState(() {
              _apiCountries = data.map((e) => Map<String, dynamic>.from(e)).toList();
              final indiaObj = _apiCountries.firstWhere(
                (e) => e['value'] == 'IN' || e['label'] == 'India',
                orElse: () => _apiCountries.first,
              );
              _selectedCountry = indiaObj['label']?.toString() ?? 'India';
              _selectedCountryCode = indiaObj['value']?.toString() ?? 'IN';
            });
          }
          if (_selectedCountryCode != null) {
            _fetchLocationStates(_selectedCountryCode!);
          }
        }
      }
    } catch (e) {
      debugPrint('Error loading API countries: $e');
    }
  }

  Future<void> _fetchLocationStates(String countryCode) async {
    try {
      final response = await ApiService.instance.get(
        ApiConstants.locationStates,
        queryParameters: {'country_code': countryCode},
      );
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        if (mounted) {
          setState(() {
            _apiStates = data.map((e) => Map<String, dynamic>.from(e)).toList();
            if (_apiStates.isNotEmpty) {
              final defaultMatch = _apiStates.firstWhere(
                (e) => e['label'] == _selectedState || e['value'] == 'GJ',
                orElse: () => _apiStates.first,
              );
              _selectedState = defaultMatch['label']?.toString();
              _selectedStateCode = defaultMatch['value']?.toString();
            } else {
              _selectedState = null;
              _selectedStateCode = null;
            }
          });
        }
        if (_selectedCountryCode != null && _selectedStateCode != null) {
          _fetchLocationCities(_selectedCountryCode!, _selectedStateCode!);
        }
      }
    } catch (e) {
      debugPrint('Error loading API states: $e');
    }
  }

  Future<void> _fetchLocationCities(String countryCode, String stateCode) async {
    try {
      final response = await ApiService.instance.get(
        ApiConstants.locationCities,
        queryParameters: {'country_code': countryCode, 'state_code': stateCode},
      );
      if (ApiService.isSuccess(response)) {
        final List data = ApiService.getData(response) ?? [];
        if (mounted) {
          setState(() {
            _apiCities = data.map((e) => Map<String, dynamic>.from(e)).toList();
            if (_apiCities.isNotEmpty) {
              final defaultMatch = _apiCities.firstWhere(
                (e) => e['label'] == _selectedCity || e['label'] == 'Surat',
                orElse: () => _apiCities.first,
              );
              _selectedCity = defaultMatch['label']?.toString();
            } else {
              _selectedCity = null;
            }
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading API cities: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initRazorpay();
    walletController.loadWalletData();
    _dateController.text = DateFormat('dd/MM/yyyy').format(DateTime.now().add(const Duration(days: 1)));
    _fetchLocationCountries();
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

  void _showSearchableSelectionModal({
    required String title,
    required List<String> items,
    required String? currentValue,
    required ValueChanged<String> onSelected,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        String searchQuery = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredItems = items
                .where((item) => item.toLowerCase().contains(searchQuery.toLowerCase()))
                .toList();

            return Container(
              height: MediaQuery.of(context).size.height * 0.75,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25.r)),
              ),
              child: Column(
                children: [
                  SizedBox(height: 12.h),
                  Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Select $title',
                          style: AppTextStyles.h4.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1E2633),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    child: TextField(
                      autofocus: true,
                      onChanged: (val) {
                        setModalState(() {
                          searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search $title...',
                        hintStyle: TextStyle(color: const Color(0xFF94A3B8), fontSize: 14.sp),
                        prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        contentPadding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.h),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.grey.shade200),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: const BorderSide(color: Color(0xFF451A03), width: 1.5),
                        ),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No matching results found',
                              style: TextStyle(color: Colors.grey[600], fontSize: 14.sp),
                            ),
                          )
                        : ListView.separated(
                            itemCount: filteredItems.length,
                            separatorBuilder: (_, __) => const Divider(height: 1, indent: 20, endIndent: 20),
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              final isSelected = item == currentValue;
                              return ListTile(
                                contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 4.h),
                                title: Text(
                                  item,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                    color: isSelected ? const Color(0xFF451A03) : const Color(0xFF1E2633),
                                  ),
                                ),
                                trailing: isSelected
                                    ? const Icon(Icons.check_circle, color: Color(0xFF451A03))
                                    : null,
                                onTap: () {
                                  Navigator.pop(context);
                                  onSelected(item);
                                },
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildShippingDetails() {
    final countriesList = _apiCountries.isNotEmpty
        ? _apiCountries.map((e) => e['label'].toString()).toList()
        : _countries;

    final statesList = _apiStates.isNotEmpty
        ? _apiStates.map((e) => e['label'].toString()).toList()
        : (_statesMap[_selectedCountry] ?? ['Gujarat', 'Maharashtra', 'Delhi']);

    final citiesList = _apiCities.isNotEmpty
        ? _apiCities.map((e) => e['label'].toString()).toList()
        : (_selectedState != null ? (_citiesMap[_selectedState!] ?? ['Ahmedabad', 'Surat', 'Mumbai', 'Other']) : <String>[]);

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
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
          SizedBox(height: 25.h),

          _buildField('PUJA DATE *', _dateController, Icons.calendar_today, readOnly: true, onTap: _selectDate),
          SizedBox(height: 16.h),

          _buildField('NAME *', _nameController, Icons.person_outline, hint: 'Enter Full Name'),
          SizedBox(height: 16.h),

          _buildField('PHONE NO *', _phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone, hint: 'Enter Phone Number'),
          SizedBox(height: 16.h),

          _buildField('FLAT NO / HOUSE NO *', _houseController, Icons.home_outlined, hint: 'Enter Flat/House Details'),
          SizedBox(height: 16.h),

          _buildField('LOCALITY *', _localityController, Icons.location_city_outlined, hint: 'Street or Area Name'),
          SizedBox(height: 16.h),

          _buildField('LANDMARK *', _landmarkController, Icons.place_outlined, hint: 'Nearby Landmark'),
          SizedBox(height: 16.h),

          _searchableSelectField(
            label: 'COUNTRY *',
            value: _selectedCountry,
            icon: Icons.public,
            hint: 'Select Country',
            onTap: () {
              _showSearchableSelectionModal(
                title: 'Country',
                items: countriesList,
                currentValue: _selectedCountry,
                onSelected: (val) {
                  setState(() {
                    _selectedCountry = val;
                    _selectedState = null;
                    _selectedCity = null;
                    _apiStates = [];
                    _apiCities = [];
                  });
                  final match = _apiCountries.firstWhere(
                    (e) => e['label'] == val,
                    orElse: () => {},
                  );
                  if (match.containsKey('value')) {
                    _selectedCountryCode = match['value']?.toString();
                    if (_selectedCountryCode != null) {
                      _fetchLocationStates(_selectedCountryCode!);
                    }
                  }
                },
              );
            },
          ),
          SizedBox(height: 16.h),

          _searchableSelectField(
            label: 'STATE *',
            value: _selectedState,
            icon: Icons.map_outlined,
            hint: 'Select State',
            onTap: () {
              _showSearchableSelectionModal(
                title: 'State',
                items: statesList,
                currentValue: _selectedState,
                onSelected: (val) {
                  setState(() {
                    _selectedState = val;
                    _selectedCity = null;
                    _apiCities = [];
                  });
                  final match = _apiStates.firstWhere(
                    (e) => e['label'] == val,
                    orElse: () => {},
                  );
                  if (match.containsKey('value')) {
                    _selectedStateCode = match['value']?.toString();
                    if (_selectedCountryCode != null && _selectedStateCode != null) {
                      _fetchLocationCities(_selectedCountryCode!, _selectedStateCode!);
                    }
                  }
                },
              );
            },
          ),
          SizedBox(height: 16.h),

          _searchableSelectField(
            label: 'CITY *',
            value: _selectedCity,
            icon: Icons.location_on_outlined,
            hint: _selectedState == null ? 'Select State First' : 'Select City',
            onTap: () {
              if (citiesList.isEmpty || citiesList.contains('Select State First')) {
                SnackbarUtil.info('Please select State first');
                return;
              }
              _showSearchableSelectionModal(
                title: 'City',
                items: citiesList,
                currentValue: _selectedCity,
                onSelected: (val) {
                  setState(() => _selectedCity = val);
                },
              );
            },
          ),
          SizedBox(height: 16.h),

          _buildField('PINCODE *', _pincodeController, Icons.pin_drop_outlined, keyboardType: TextInputType.number, hint: '6-digit Pincode'),
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

  Widget _searchableSelectField({
    required String label,
    required String? value,
    required IconData icon,
    required String hint,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w900, color: const Color(0xFF64748B), fontSize: 11.sp, letterSpacing: 0.5)),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: const Color(0xFFCBD5E1)),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: value != null ? FontWeight.bold : FontWeight.normal,
                      color: value != null ? const Color(0xFF1E2633) : const Color(0xFF94A3B8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.search, size: 18.sp, color: const Color(0xFF94A3B8)),
              ],
            ),
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
      'phone': _phoneController.text,
      'phone_no': _phoneController.text,
      'flat_no': _houseController.text,
      'flat_house_no': _houseController.text,
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
      astrologerId: _getAstrologerId(),
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
      final String rzpOrderId = paymentData['id']?.toString() ?? '';
      final Map<String, dynamic> options = {
        'key': AppConstants.razorpayKeyId,
        'amount': paymentData['amount'],
        'name': 'Puja Booking',
        'description': widget.puja.title,
        'prefill': {
          'contact': _phoneController.text.isNotEmpty ? _phoneController.text : '9904755099',
          'email': 'admin@thekhushiempire.com',
        },
        'theme': {'color': '#E65100'},
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
      };

      if (rzpOrderId.isNotEmpty && !rzpOrderId.startsWith('order_sim_')) {
        options['order_id'] = rzpOrderId;
      }

      try {
        _razorpay.open(options);
      } catch (e) {
        SnackbarUtil.error('Failed to open payment gateway: $e');
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
      'phone_no': _phoneController.text,
      'flat_no': _houseController.text,
      'flat_house_no': _houseController.text,
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
      astrologerId: _getAstrologerId(),
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
