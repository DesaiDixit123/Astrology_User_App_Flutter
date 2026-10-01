import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../config/routes/app_routes.dart';
import '../../../../core/localization/app_language_controller.dart';
import '../../data/calendar_engine.dart';
import '../controllers/service_controller.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  late DateTime _selectedDate;
  late DateTime _currentMonth;
  int _selectedTabIndex = 0;
  bool _isDayChoghadiya = true;
  late final AppLanguageController _langController;
  ServiceController? _serviceController;
  String? _lastGlobalLang;
  String? _calendarLang;

  /// Returns the active calendar viewing language:
  /// - Defaults to the global app setting language.
  /// - If the app settings language changes, calendar automatically syncs with it.
  /// - If user toggles language inside the calendar page, only this page changes without affecting the app.
  String get _effectiveCalendarLang {
    final currentGlobal = CalendarEngine.normalizeLang(_langController.currentLanguageCode);
    if (_lastGlobalLang != currentGlobal) {
      _lastGlobalLang = currentGlobal;
      _calendarLang = currentGlobal;
    }
    return _calendarLang ?? currentGlobal;
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _currentMonth = DateTime(now.year, now.month, 1);

    _langController = Get.isRegistered<AppLanguageController>()
        ? Get.find<AppLanguageController>()
        : Get.put(AppLanguageController());

    if (Get.isRegistered<ServiceController>()) {
      _serviceController = Get.find<ServiceController>();
    } else {
      try {
        _serviceController = Get.put(ServiceController());
      } catch (_) {}
    }

    _fetchLivePanchang();
  }

  void _fetchLivePanchang() {
    try {
      final formatted = DateFormat('yyyy-MM-dd').format(_selectedDate);
      final lang = _effectiveCalendarLang;
      _serviceController?.getPanchangByDate(date: formatted, language: lang);
    } catch (e) {
      debugPrint('Live panchang fetch error: $e');
    }
  }

  void _goToPreviousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _goToNextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    final now = DateTime.now();
    setState(() {
      _selectedDate = DateTime(now.year, now.month, now.day);
      _currentMonth = DateTime(now.year, now.month, 1);
    });
    _fetchLivePanchang();
  }

  Future<void> _selectYearMonth(BuildContext context, String currentLang) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      initialDatePickerMode: DatePickerMode.year,
      helpText: CalendarEngine.getUiText('title', currentLang),
    );

    if (picked != null) {
      setState(() {
        _currentMonth = DateTime(picked.year, picked.month, 1);
        _selectedDate = DateTime(picked.year, picked.month, picked.day);
      });
      _fetchLivePanchang();
    }
  }

  String _formatLocalizedDate(DateTime date, String lang) {
    final l = CalendarEngine.normalizeLang(lang);
    if (l == CalendarEngine.langGu) {
      const gujDays = [
        'સોમવાર', 'મંગળવાર', 'બુધવાર', 'ગુરુવાર', 'શુક્રવાર', 'શનિવાર', 'રવિવાર'
      ];
      const gujMonths = [
        'જાન્યુઆરી', 'ફેબ્રુઆરી', 'માર્ચ', 'એપ્રિલ', 'મે', 'જૂન',
        'જુલાઈ', 'ઓગસ્ટ', 'સપ્ટેમ્બર', 'ઓક્ટોબર', 'નવેમ્બર', 'ડિસેમ્બર'
      ];
      final dayName = gujDays[date.weekday - 1];
      final monthName = gujMonths[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    } else if (l == CalendarEngine.langHi) {
      const hiDays = [
        'सोमवार', 'मंगलवार', 'बुधवार', 'गुरुवार', 'शुक्रवार', 'शनिवार', 'रविवार'
      ];
      const hiMonths = [
        'जनवरी', 'फ़रवरी', 'मार्च', 'अप्रैल', 'मई', 'जून',
        'जुलाई', 'अगस्त', 'सितम्बर', 'अक्टूबर', 'नवम्बर', 'दिसम्बर'
      ];
      final dayName = hiDays[date.weekday - 1];
      final monthName = hiMonths[date.month - 1];
      return '$dayName, ${date.day} $monthName ${date.year}';
    }
    return DateFormat('EEEE, d MMMM yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentLang = _effectiveCalendarLang;
      final pageTitle = CalendarEngine.getUiText('title', currentLang);
      final samvatStr = '${CalendarEngine.getUiText('samvat_prefix', currentLang)} ${CalendarEngine.getVikramSamvat(_currentMonth.year, _currentMonth.month, currentLang)}';
      final todayStr = CalendarEngine.getUiText('today', currentLang);

      return Scaffold(
        backgroundColor: const Color(0xFFFBF8F2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Get.back(),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                pageTitle,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 16.sp,
                ),
              ),
              Text(
                samvatStr,
                style: TextStyle(
                  color: AppColors.shopMaroon,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _goToToday,
              child: Text(
                todayStr,
                style: TextStyle(
                  color: AppColors.shopMaroon,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Language Selector Bar (English, हिन्दी, ગુજરાતી)
              _buildLanguageSwitcherBar(currentLang),

              // Month Navigation Header
              _buildMonthHeader(currentLang),

              // Weekdays Header (Sun -> Sat)
              _buildWeekdaysHeader(currentLang),

              // Calendar Grid with Festivals & Bank Holidays
              _buildDaysGrid(currentLang),

              SizedBox(height: 12.h),

              // Active Selected Date Overview
              _buildSelectedDateDirectOverview(currentLang),

              SizedBox(height: 16.h),

              // Category Tab Pills
              _buildCategoryTabs(currentLang),

              SizedBox(height: 12.h),

              // Active Tab Content
              _buildTabContent(currentLang),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      );
    });
  }

  // ── Language Selector Bar ──────────────────────────────────────────────────
  Widget _buildLanguageSwitcherBar(String currentLang) {
    const options = [
      {'code': 'gu', 'label': 'ગુજરાતી'},
      {'code': 'hi', 'label': 'हिन्दी'},
      {'code': 'en', 'label': 'English'},
    ];

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: options.map((opt) {
          final isSelected = currentLang == opt['code'];
          return GestureDetector(
            onTap: () {
              if (!isSelected) {
                setState(() {
                  _calendarLang = opt['code']!;
                });
                _fetchLivePanchang();
              }
            },
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.shopMaroon : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(
                  color: isSelected ? AppColors.shopMaroon : Colors.grey.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                opt['label']!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Month Header ───────────────────────────────────────────────────────────
  Widget _buildMonthHeader(String currentLang) {
    final engMonth = DateFormat('MMMM yyyy').format(_currentMonth);
    final hinduMonth = CalendarEngine.getHinduMonthName(_currentMonth.month, currentLang);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, color: Colors.black87, size: 28),
            onPressed: _goToPreviousMonth,
          ),
          GestureDetector(
            onTap: () => _selectYearMonth(context, currentLang),
            child: Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hinduMonth,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.shopMaroon,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_drop_down, color: AppColors.shopMaroon, size: 20.sp),
                  ],
                ),
                SizedBox(height: 2.h),
                Text(
                  engMonth,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, color: Colors.black87, size: 28),
            onPressed: _goToNextMonth,
          ),
        ],
      ),
    );
  }

  // ── Weekdays Header ────────────────────────────────────────────────────────
  Widget _buildWeekdaysHeader(String currentLang) {
    final weekdays = CalendarEngine.getWeekdays(currentLang);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(
        children: List.generate(weekdays.length, (index) {
          final day = weekdays[index];
          final isSun = index == 0;
          return Expanded(
            child: Center(
              child: Text(
                day['short']!,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: isSun ? Colors.red.shade600 : Colors.brown.shade700,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Calendar Grid ──────────────────────────────────────────────────────────
  Widget _buildDaysGrid(String currentLang) {
    final daysInMonth = DateUtils.getDaysInMonth(_currentMonth.year, _currentMonth.month);
    final firstDayOfWeek = DateTime(_currentMonth.year, _currentMonth.month, 1).weekday % 7;

    final totalBoxes = firstDayOfWeek + daysInMonth;
    final rowCount = (totalBoxes / 7).ceil();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      child: Column(
        children: List.generate(rowCount, (rowIndex) {
          return Row(
            children: List.generate(7, (colIndex) {
              final boxIndex = rowIndex * 7 + colIndex;
              final dayNumber = boxIndex - firstDayOfWeek + 1;

              if (dayNumber < 1 || dayNumber > daysInMonth) {
                return const Expanded(child: SizedBox(height: 70));
              }

              final date = DateTime(_currentMonth.year, _currentMonth.month, dayNumber);
              final isSelected = date.year == _selectedDate.year &&
                  date.month == _selectedDate.month &&
                  date.day == _selectedDate.day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;
              final isSunday = colIndex == 0;

              final tithiShort = CalendarEngine.getShortTithi(date, currentLang);
              final isPoonam = tithiShort == 'પૂનમ' || tithiShort == 'पूर्णिमा' || tithiShort == 'Purnima';
              final isAmas = tithiShort == 'અમાસ' || tithiShort == 'अमावस्या' || tithiShort == 'Amavasya';
              final isEkadashi = tithiShort == 'અગિયારસ' || tithiShort == 'एकादशी' || tithiShort == 'Ekadashi';

              // Festival check
              final festivalName = CalendarEngine.getFestival(_currentMonth.month, dayNumber, currentLang);
              final hasFestival = festivalName != null && festivalName.isNotEmpty;

              // Bank Holiday check
              final isBankHoliday = CalendarEngine.isDateBankHoliday(
                _currentMonth.year,
                _currentMonth.month,
                dayNumber,
                currentLang,
              );

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                    _fetchLivePanchang();
                  },
                  child: Container(
                    height: 70.h,
                    margin: EdgeInsets.all(2.w),
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.shopMaroon
                          : (hasFestival
                              ? const Color(0xFFFFF7ED)
                              : (isToday ? const Color(0xFFFDE8E4) : Colors.transparent)),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.shopMaroon
                            : (hasFestival
                                ? Colors.orange.shade300
                                : (isToday ? AppColors.shopMaroon : Colors.grey.shade200)),
                        width: isSelected || isToday ? 1.4 : 0.8,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Date number row + Bank Holiday icon
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '$dayNumber',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: isSelected || isToday ? FontWeight.bold : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : (isSunday ? Colors.red.shade600 : Colors.black87),
                              ),
                            ),
                            if (isBankHoliday && !isSelected) ...[
                              SizedBox(width: 1.w),
                              Icon(Icons.account_balance, size: 8.sp, color: Colors.indigo.shade600),
                            ],
                          ],
                        ),

                        // Festival Badge — full text via FittedBox
                        if (hasFestival) ...[
                          SizedBox(height: 2.h),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.h),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.amber.shade300 : const Color(0xFFEA580C),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: Text(
                                festivalName,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                style: TextStyle(
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.black87 : Colors.white,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          // Tithi text — FittedBox auto-scales
                          SizedBox(height: 2.h),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: Text(
                              tithiShort,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: (isPoonam || isAmas || isEkadashi)
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.9)
                                    : ((isPoonam || isEkadashi)
                                        ? Colors.orange.shade800
                                        : (isAmas ? Colors.blueGrey : Colors.grey.shade600)),
                              ),
                            ),
                          ),

                        ],
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  // ── Selected Date Overview Banner ──────────────────────────────────────────
  Widget _buildSelectedDateDirectOverview(String currentLang) {
    final localizedFullDate = _formatLocalizedDate(_selectedDate, currentLang);
    final tithi = CalendarEngine.getTithiName(_selectedDate, currentLang);
    final hinduMonth = CalendarEngine.getHinduMonthName(_selectedDate.month, currentLang);
    final festival = CalendarEngine.getFestival(_selectedDate.month, _selectedDate.day, currentLang);
    final isBankHoliday = CalendarEngine.isDateBankHoliday(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      currentLang,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.shopMaroon.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.event_available_rounded, color: AppColors.shopMaroon, size: 20.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizedFullDate,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      Text(
                        '${CalendarEngine.getUiText('tithi_label', currentLang)}: $tithi  •  $hinduMonth',
                        style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (festival != null && festival.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFEA580C), Color(0xFFC2410C)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.celebration_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        CalendarEngine.getUiText('special_festival', currentLang, festival),
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (isBankHoliday) ...[
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.indigo.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_balance, color: Colors.indigo.shade700, size: 16),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        CalendarEngine.getUiText('bank_holiday_banner', currentLang),
                        style: TextStyle(color: Colors.indigo.shade800, fontWeight: FontWeight.w600, fontSize: 11.sp),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Category Tab Pills ─────────────────────────────────────────────────────
  Widget _buildCategoryTabs(String currentLang) {
    final tabs = CalendarEngine.getTabs(currentLang);

    return SizedBox(
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        itemCount: tabs.length,
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final isSelected = _selectedTabIndex == index;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedTabIndex = index;
              });
            },
            child: Container(
              margin: EdgeInsets.only(right: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.shopMaroon : Colors.white,
                borderRadius: BorderRadius.circular(22.r),
                border: Border.all(
                  color: isSelected ? AppColors.shopMaroon : Colors.grey.shade300,
                  width: 1,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.shopMaroon.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    tab['icon'] as IconData,
                    size: 15.sp,
                    color: isSelected ? Colors.white : AppColors.shopMaroon,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    tab['title'] as String,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Tab Content Switcher ───────────────────────────────────────────────────
  Widget _buildTabContent(String currentLang) {
    switch (_selectedTabIndex) {
      case 0:
        return _buildChoghadiyaSection(currentLang);
      case 1:
        return _buildFestivalsSection(currentLang);
      case 2:
        return _buildBankHolidaysSection(currentLang);
      case 3:
        return _buildPublicHolidaysSection(currentLang);
      case 4:
        return _buildMuhuratSection(currentLang);
      case 5:
        return _buildCalendarDetailsSection(currentLang);
      case 6:
        return _buildVratKathaSection(currentLang);
      default:
        return _buildChoghadiyaSection(currentLang);
    }
  }

  // ── 1. Dynamic Choghadiya Section ──────────────────────────────────────────
  Widget _buildChoghadiyaSection(String currentLang) {
    final dateStr = DateFormat('dd/MM/yyyy').format(_selectedDate);
    final choghadiyaList = CalendarEngine.calculateChoghadiya(
      _selectedDate,
      isDay: _isDayChoghadiya,
      lang: currentLang,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  CalendarEngine.getUiText('choghadiya_for_date', currentLang, dateStr),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Day / Night Toggle
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDayChoghadiya = true),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: _isDayChoghadiya ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          if (_isDayChoghadiya)
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wb_sunny_rounded, size: 16.sp, color: Colors.orange.shade700),
                          SizedBox(width: 6.w),
                          Text(
                            CalendarEngine.getUiText('day_choghadiya', currentLang),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: _isDayChoghadiya ? FontWeight.bold : FontWeight.w500,
                              color: _isDayChoghadiya ? Colors.black87 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _isDayChoghadiya = false),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 8.h),
                      decoration: BoxDecoration(
                        color: !_isDayChoghadiya ? Colors.white : Colors.transparent,
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          if (!_isDayChoghadiya)
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.nights_stay_rounded, size: 16.sp, color: Colors.indigo),
                          SizedBox(width: 6.w),
                          Text(
                            CalendarEngine.getUiText('night_choghadiya', currentLang),
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: !_isDayChoghadiya ? FontWeight.bold : FontWeight.w500,
                              color: !_isDayChoghadiya ? Colors.black87 : Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),

          ...choghadiyaList.map((c) {
            Color tagColor;
            Color bgColor;
            String statusBadge;

            if (c['type'] == 'good') {
              tagColor = const Color(0xFF16A34A);
              bgColor = const Color(0xFFF0FDF4);
              statusBadge = CalendarEngine.getUiText('good', currentLang);
            } else if (c['type'] == 'bad') {
              tagColor = const Color(0xFFDC2626);
              bgColor = const Color(0xFFFEF2F2);
              statusBadge = CalendarEngine.getUiText('bad', currentLang);
            } else {
              tagColor = const Color(0xFFD97706);
              bgColor = const Color(0xFFFFFBEB);
              statusBadge = CalendarEngine.getUiText('neutral', currentLang);
            }

            final isActive = c['isActive'] == true;

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isActive ? AppColors.shopMaroon : Colors.grey.shade200,
                  width: isActive ? 1.5 : 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isActive
                        ? AppColors.shopMaroon.withValues(alpha: 0.1)
                        : Colors.black.withValues(alpha: 0.02),
                    blurRadius: isActive ? 6 : 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left circle with choghadiya name
                  Container(
                    width: 42.w,
                    height: 42.w,
                    decoration: BoxDecoration(
                      color: bgColor,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      c['name']!,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: tagColor),
                    ),
                  ),
                  SizedBox(width: 10.w),

                  // Middle: Name (bold) + Nature (grey) + Time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name title
                        Text(
                          c['name']!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: tagColor,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        // Nature description — full text, wraps to 2 lines if needed
                        Text(
                          c['nature']!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                            height: 1.2,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        // Time + Active badge side by side
                        Row(
                          children: [
                            Icon(Icons.access_time_rounded, size: 12.sp, color: Colors.grey.shade500),
                            SizedBox(width: 3.w),
                            Flexible(
                              child: Text(
                                c['time']!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500),
                              ),
                            ),
                            if (isActive) ...[
                              SizedBox(width: 6.w),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                                decoration: BoxDecoration(
                                  color: AppColors.shopMaroon,
                                  borderRadius: BorderRadius.circular(5.r),
                                ),
                                child: Text(
                                  CalendarEngine.getUiText('current_active', currentLang),
                                  style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Right badge: Good / Inauspicious / Neutral
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: tagColor.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      statusBadge,
                      style: TextStyle(color: tagColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );

          }),
        ],
      ),
    );
  }

  // ── 2. Dynamic Festivals Section ───────────────────────────────────────────
  Widget _buildFestivalsSection(String currentLang) {
    final currentMonthFestivals = CalendarEngine.getFestivalsForMonth(_currentMonth.month, currentLang);
    final monthName = CalendarEngine.getHinduMonthName(_currentMonth.month, currentLang);
    final engMonth = DateFormat('MMMM yyyy').format(_currentMonth);

    if (currentMonthFestivals.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 20.h),
        child: Center(
          child: Text(CalendarEngine.getUiText('no_festivals', currentLang)),
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CalendarEngine.getUiText('festivals_of_month', currentLang, '$monthName ($engMonth)'),
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 10.h),
          ...currentMonthFestivals.entries.map((e) {
            final day = e.key;
            final festivalName = e.value;
            final date = DateTime(_currentMonth.year, _currentMonth.month, day);
            final tithi = CalendarEngine.getTithiName(date, currentLang);

            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFFF7ED),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: const Color(0xFFEA580C)),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(festivalName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 2.h),
                        Text(tithi, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Text(
                    DateFormat('d MMM').format(date),
                    style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: AppColors.shopMaroon),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 3. Dynamic Bank Holidays Section ───────────────────────────────────────
  Widget _buildBankHolidaysSection(String currentLang) {
    final bankHolidays = CalendarEngine.getBankHolidaysForMonth(
      _currentMonth.year,
      _currentMonth.month,
      currentLang,
    );
    final monthName = CalendarEngine.getHinduMonthName(_currentMonth.month, currentLang);
    final engMonth = DateFormat('MMMM yyyy').format(_currentMonth);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  CalendarEngine.getUiText('bank_holidays_of_month', currentLang, '$monthName ($engMonth)'),
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade50,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  CalendarEngine.getUiText('total_holidays', currentLang, bankHolidays.length.toString()),
                  style: TextStyle(fontSize: 11.sp, color: Colors.indigo.shade700, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          if (bankHolidays.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(CalendarEngine.getUiText('no_holidays', currentLang)),
              ),
            )
          else
            ...bankHolidays.map((b) {
              final day = b['day'] as int;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final weekdayName = DateFormat('EEEE').format(date);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.indigo.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b['name'] as String, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          Text('${b['note']}  •  $weekdayName', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        DateFormat('d MMM').format(date),
                        style: TextStyle(color: Colors.indigo, fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── 4. Dynamic Public Holidays Section ─────────────────────────────────────
  Widget _buildPublicHolidaysSection(String currentLang) {
    final pubHolidays = CalendarEngine.getPublicHolidaysForMonth(
      _currentMonth.year,
      _currentMonth.month,
      currentLang,
    );
    final monthName = CalendarEngine.getHinduMonthName(_currentMonth.month, currentLang);
    final engMonth = DateFormat('MMMM yyyy').format(_currentMonth);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CalendarEngine.getUiText('public_holidays_of_month', currentLang, '$monthName ($engMonth)'),
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          SizedBox(height: 10.h),
          if (pubHolidays.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(20.h),
                child: Text(CalendarEngine.getUiText('no_holidays', currentLang)),
              ),
            )
          else
            ...pubHolidays.map((h) {
              final day = h['day'] as int;
              final date = DateTime(_currentMonth.year, _currentMonth.month, day);
              final weekdayName = DateFormat('EEEE').format(date);

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$day',
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.teal.shade800),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h['name'] as String, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                          Text(weekdayName, style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.teal.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        DateFormat('d MMM').format(date),
                        style: TextStyle(color: Colors.teal.shade800, fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── 5. Dynamic Muhurat Section ─────────────────────────────────────────────
  Widget _buildMuhuratSection(String currentLang) {
    final muhurats = CalendarEngine.getMuhurats(currentLang);
    final header = currentLang == CalendarEngine.langHi
        ? 'शुभ मुहूर्त २०२६-२०२७'
        : (currentLang == CalendarEngine.langEn
            ? 'Auspicious Muhurat 2026-2027'
            : 'શુભ મુહૂર્ત ૨૦૨૬-૨૦૨૭');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          ...muhurats.map((m) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: (m['color'] as Color).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(m['icon'] as IconData, color: m['color'] as Color, size: 22.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(m['title'] as String, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4.h),
                        Text(
                          m['dates'] as String,
                          style: TextStyle(fontSize: 12.sp, color: AppColors.shopMaroon, fontWeight: FontWeight.w600),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          m['desc'] as String,
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 6. Dynamic Panchang Details Section ────────────────────────────────────
  Widget _buildCalendarDetailsSection(String currentLang) {
    final rawLiveData = _serviceController?.panchangResult;
    final Map<String, dynamic>? liveData = (rawLiveData != null && rawLiveData.isNotEmpty)
        ? Map<String, dynamic>.from(rawLiveData)
        : null;
    final details = CalendarEngine.getPanchangDetails(
      _selectedDate,
      currentLang,
      liveData: liveData,
    );
    final labels = details['labels'] as Map<String, String>;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Container(
        padding: EdgeInsets.all(18.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(labels['card_title']!, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
                if (_serviceController?.isLoading.value == true)
                  SizedBox(
                    width: 14.w,
                    height: 14.w,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            Divider(height: 20.h, color: Colors.grey.shade200),
            _buildDetailRow(labels['date']!, details['dateStr']),
            _buildDetailRow(labels['samvat']!, details['samvat']),
            _buildDetailRow(labels['month']!, details['month']),
            _buildDetailRow(labels['tithi']!, details['tithi']),
            _buildDetailRow(labels['paksha']!, details['paksha']),
            _buildDetailRow(labels['nakshatra']!, details['nakshatra']),
            _buildDetailRow(labels['yoga']!, details['yoga']),
            _buildDetailRow(labels['karana']!, details['karana']),
            _buildDetailRow(labels['sun']!, details['sun']),
            _buildDetailRow(labels['rahu']!, details['rahu']),
            _buildDetailRow(labels['abhijit']!, details['abhijit']),
            SizedBox(height: 12.h),
            ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.panchang),
              icon: Icon(Icons.wb_sunny_outlined, size: 16.sp),
              label: Text(CalendarEngine.getUiText('view_full_panchang', currentLang)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.shopMaroon,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── 7. Dynamic Vrat Kathas Section ─────────────────────────────────────────
  Widget _buildVratKathaSection(String currentLang) {
    final kathas = CalendarEngine.getVratKathas(currentLang);
    final header = currentLang == CalendarEngine.langHi
        ? 'पवित्र व्रत कथाएं'
        : (currentLang == CalendarEngine.langEn
            ? 'Sacred Vrat Stories (Kathas)'
            : 'પવિત્ર વ્રત કથાઓ');

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(header, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 10.h),
          ...kathas.map((k) {
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(8.w),
                        decoration: BoxDecoration(
                          color: AppColors.shopMaroon.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.menu_book_rounded, color: AppColors.shopMaroon, size: 20.sp),
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          k['title']!,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    k['desc']!,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, height: 1.3),
                  ),
                  SizedBox(height: 10.h),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton(
                      onPressed: () {
                        _showKathaModal(k['title']!, k['detail']!, currentLang);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.shopMaroon,
                        side: BorderSide(color: AppColors.shopMaroon),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      ),
                      child: Text(
                        CalendarEngine.getUiText('read_button', currentLang),
                        style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showKathaModal(String title, String content, String currentLang) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.only(bottom: 16.h),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Row(
                children: [
                  Icon(Icons.menu_book_rounded, color: AppColors.shopMaroon),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                ],
              ),
              Divider(height: 24.h),
              Text(
                content,
                style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.6),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.shopMaroon,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(CalendarEngine.getUiText('close_button', currentLang)),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
          Text(
            value,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
