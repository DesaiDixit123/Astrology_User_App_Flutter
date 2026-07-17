import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';

import 'package:intl/intl.dart';
import '../controllers/service_controller.dart';
import '../../../../core/localization/app_language_controller.dart';

class PanchangPage extends StatefulWidget {
  const PanchangPage({super.key});

  @override
  State<PanchangPage> createState() => _PanchangPageState();
}

class _PanchangPageState extends State<PanchangPage> {
  final ServiceController controller = Get.find<ServiceController>();

  // UI state
  String _selectedType = 'today'; // 'today' or 'tomorrow'
  DateTime _selectedDate = DateTime.now();
  late AppLanguageController langController;

  @override
  void initState() {
    super.initState();
    langController = Get.find<AppLanguageController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchPanchangForSelectedDate();
    });
  }

  void _fetchPanchangForSelectedDate() {
    final language = langController.currentLanguageCode;
    // Check if the selected date is technically 'today' or 'tomorrow' dynamically
    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));
    
    if (_selectedDate.year == now.year && _selectedDate.month == now.month && _selectedDate.day == now.day) {
        _selectedType = 'today';
        controller.getTodayPanchang(language: language);
    } else if (_selectedDate.year == tomorrow.year && _selectedDate.month == tomorrow.month && _selectedDate.day == tomorrow.day) {
        _selectedType = 'tomorrow';
        controller.getTomorrowPanchang(language: language);
    } else {
        _selectedType = 'byDate';
        final dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);
        controller.getPanchangByDate(
          date: dateStr,
          language: language,
        );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: Color(0xFF5C2D16)),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchPanchangForSelectedDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFDF8EE), // Pale cream background matching image
      appBar: AppBar(
        title: const Text('Panchang'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.panchangResult.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF5C2D16)));
        }

        final result = controller.panchangResult;
        if (result.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Failed to load Panchang'),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () => _fetchPanchangForSelectedDate(),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5C2D16)),
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        }

        final p = result;
        final tithi = p['tithi'] ?? 'N/A';
        final nakshatra = p['nakshatra'] ?? 'N/A';
        final yoga = p['yoga'] ?? 'N/A';
        final karana = p['karana'] ?? 'N/A';
        final rasi = p['rasi'] ?? 'N/A';

        final sunrise = p['sunrise'] ?? 'N/A';
        final sunset = p['sunset'] ?? 'N/A';
        final moonrise = p['moonrise'] ?? 'N/A';
        final moonset = p['moonset'] ?? 'N/A';
        final amantaMonth = p['amanta_month'] ?? 'N/A';
        final paksha = p['paksha'] ?? 'N/A';
        final samvat = p['samvat'] ?? 'N/A';

        return SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: Colors.white,
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_outlined, size: 16.sp, color: Colors.brown.shade800),
                            SizedBox(width: 8.w),
                            Text(DateFormat('yyyy-MM-dd').format(_selectedDate), style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                            SizedBox(width: 8.w),
                            Icon(Icons.keyboard_arrow_down, size: 16.sp, color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(24.r),
                      ),
                      child: Row(
                        children: [
                          _buildToggleBtn('TODAY', _selectedType == 'today', () {
                             setState(() {
                               _selectedDate = DateTime.now();
                             });
                             _fetchPanchangForSelectedDate();
                          }),
                          _buildToggleBtn('TOMORROW', _selectedType == 'tomorrow', () {
                             setState(() {
                               _selectedDate = DateTime.now().add(const Duration(days: 1));
                             });
                             _fetchPanchangForSelectedDate();
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    _buildPanchangCard(
                      'PANCHANG DETAILS',
                      [
                        _buildRowItem('TITHI', tithi.toString()),
                        _buildRowItem('NAKSHATRA', nakshatra.toString()),
                        _buildRowItem('YOGA', yoga.toString()),
                        _buildRowItem('KARANA', karana.toString()),
                        _buildRowItem('RASI', rasi.toString()),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    _buildPanchangCard(
                      'ADDITIONAL INFO',
                      [
                        _buildRowWithIcon('SUNRISE', sunrise.toString(), Icons.wb_sunny_outlined, Colors.orange),
                        _buildRowWithIcon('SUNSET', sunset.toString(), Icons.brightness_6_outlined, Colors.red),
                        _buildRowWithIcon('MOONRISE', moonrise.toString(), Icons.nightlight_round, Colors.indigo),
                        _buildRowWithIcon('MOONSET', moonset.toString(), Icons.brightness_3, Colors.blueGrey),
                        _buildRowWithIcon('AMANTA MONTH', amantaMonth.toString(), Icons.calendar_month_outlined, Colors.purple),
                        _buildRowWithIcon('PAKSHA', paksha.toString(), Icons.incomplete_circle, Colors.blue),
                        _buildRowWithIcon('SAMVAT', samvat.toString(), Icons.star_border, Colors.pink),
                      ],
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildToggleBtn(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF5C2D16) : Colors.transparent, // Brown matching image
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildPanchangCard(String header, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: const Color(0xFFF1FAF4), // light green
              borderRadius: BorderRadius.only(topLeft: Radius.circular(16.r), topRight: Radius.circular(16.r)),
            ),
            width: double.infinity,
            alignment: Alignment.center,
            child: Text(
              header,
              style: TextStyle(
                color: const Color(0xFF1B5E20), // Dark green text
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                fontSize: 14.sp,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              children: children,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
              fontSize: 12.sp,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  Widget _buildRowWithIcon(String label, String value, IconData icon, Color iconColor) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Icon(icon, color: iconColor, size: 16.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w900,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }
}
