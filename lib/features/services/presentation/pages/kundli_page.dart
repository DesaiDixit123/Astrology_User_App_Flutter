import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../controllers/kundli_controller.dart';

class KundliPage extends GetView<KundliController> {
  KundliPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF8F5), // Light cream background
      appBar: AppBar(
        title: Text('free_janam_kundali'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 24.h + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
            _buildHeaderMenu(),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildInputSection(context),
                  SizedBox(height: 32.h),
                  _buildResultTabs(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderMenu() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuTab('free_janam_kundali'.tr, true),
            SizedBox(width: 12.w),
            _buildMenuTab(
              'kundali_matching'.tr,
              false,
              onTap: () => Get.offNamed('/matchmaking'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTab(String title, bool isSelected, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20.r),
          border: isSelected
              ? null
              : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          title,
          style: AppTextStyles.bodySmall.copyWith(
            color: isSelected ? Colors.white : AppColors.primary,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline, color: Colors.brown, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                'enter_details'.tr,
                style: AppTextStyles.h4.copyWith(
                  color: Colors.brown,
                  letterSpacing: 1.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth > 600) {
                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: '${'full_name'.tr} *',
                            hint: 'enter_your_name'.tr,
                            controller: controller.kundliNameController,
                            icon: Icons.person_outline,
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildDatePicker(context)),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(child: _buildTimePicker(context)),
                        SizedBox(width: 16.w),
                        Expanded(child: _buildGenderDropdown()),
                      ],
                    ),
                  ],
                );
              } else {
                return Column(
                  children: [
                    _buildTextField(
                      label: '${'full_name'.tr} *',
                      hint: 'enter_your_name'.tr,
                      controller: controller.kundliNameController,
                      icon: Icons.person_outline,
                    ),
                    SizedBox(height: 16.h),
                    _buildDatePicker(context),
                    SizedBox(height: 16.h),
                    _buildTimePicker(context),
                    SizedBox(height: 16.h),
                    _buildGenderDropdown(),
                  ],
                );
              }
            },
          ),
          SizedBox(height: 16.h),
          _buildPlaceAutocomplete(
            label: '${'place_of_birth'.tr} *',
            hint: 'city_hint'.tr,
            controller: controller.kundliPlaceController,
            onPlaceSelected: (lat, lon) {
              controller.lat = lat;
              controller.lon = lon;
            },
          ),
          SizedBox(height: 32.h),
          Center(
            child: Obx(
              () => SizedBox(
                width: 250.w,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () => controller.getKundli(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(
                      0xFF5D3012,
                    ), // Dark brown color from web
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.r),
                    ),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 18.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              'generate_kundali'.tr,
                              style: AppTextStyles.button.copyWith(
                                color: Colors.white,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    required TextEditingController controller,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          decoration: _inputDecoration(hint, icon: icon),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Date *',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller.kundliDobController,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.kundliDobController.text =
                  "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          },
          decoration: _inputDecoration(
            'DD/MM/YYYY',
            icon: Icons.calendar_today_outlined,
          ),
        ),
      ],
    );
  }

  Widget _buildTimePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birth Time *',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(
          () => TextFormField(
            controller: controller.kundliTobController,
            readOnly: true,
            enabled: !controller.timeUnknown.value,
            onTap: () async {
              if (controller.timeUnknown.value) return;
              final picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                controller.kundliTobController.text =
                    "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              }
            },
            decoration: _inputDecoration('HH:MM', icon: Icons.access_time),
          ),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(
              () => Checkbox(
                value: controller.timeUnknown.value,
                onChanged: (val) => controller.timeUnknown.value = val ?? false,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
              ),
            ),
            Text(
              "Don't know birth time",
              style: AppTextStyles.bodySmall.copyWith(
                fontSize: 10.sp,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gender *',
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Obx(
          () => DropdownButtonFormField<String>(
            value: controller.kundliGender.value,
            items: ['Male', 'Female'].map((String val) {
              return DropdownMenuItem<String>(
                value: val,
                child: Text(val, style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: (newVal) {
              if (newVal != null) controller.kundliGender.value = newVal;
            },
            decoration: _inputDecoration(''),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey,
              size: 20.sp,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceAutocomplete({
    required String label,
    required String hint,
    required TextEditingController controller,
    required Function(String lat, String lon) onPlaceSelected,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11.sp,
          ),
        ),
        SizedBox(height: 6.h),
        Autocomplete<Map<String, dynamic>>(
          initialValue: controller.value,
          optionsBuilder: (TextEditingValue textEditingValue) async {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<Map<String, dynamic>>.empty();
            }
            return await this.controller.searchPlaces(textEditingValue.text);
          },
          displayStringForOption: (option) => option['description'] as String,
          onSelected: (option) {
            controller.text = option['description'];
            if (option['lat'] != null && option['lon'] != null) {
              onPlaceSelected(option['lat'].toString(), option['lon'].toString());
            }
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 6.0,
                borderRadius: BorderRadius.circular(12.r),
                color: Colors.white,
                child: Container(
                  width: MediaQuery.of(context).size.width - 64.w,
                  constraints: BoxConstraints(maxHeight: 220.h),
                  child: ListView.separated(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: options.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final option = options.elementAt(index);
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.location_on, color: Colors.orange, size: 18),
                        title: Text(
                          option['description'] ?? '',
                          style: AppTextStyles.bodySmall.copyWith(color: Colors.black87, fontWeight: FontWeight.w600),
                        ),
                        onTap: () {
                          onSelected(option);
                        },
                      );
                    },
                  ),
                ),
              ),
            );
          },
          fieldViewBuilder:
              (context, textEditingController, focusNode, onFieldSubmitted) {
                if (controller.text.isNotEmpty && textEditingController.text.isEmpty) {
                  textEditingController.text = controller.text;
                }
                return TextField(
                  controller: textEditingController,
                  focusNode: focusNode,
                  onChanged: (val) {
                    controller.text = val;
                  },
                  decoration: _inputDecoration(
                    hint,
                    icon: Icons.location_on_outlined,
                  ),
                );
              },
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
      suffixIcon: icon != null
          ? Icon(icon, color: Colors.grey.shade400, size: 20.sp)
          : null,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.r),
        borderSide: const BorderSide(color: Colors.brown),
      ),
    );
  }

  Widget _buildResultTabs() {
    return Obx(() {
      if (controller.kundliResult.isEmpty) return const SizedBox.shrink();

      final tabs = [
        'Basic Details',
        'Planetary Position',
        'Predictions',
        'Shodashvarga',
        'Ashtakvarga',
        'Mahadasha',
        'Yogini Dasha',
        'Dosha',
        'Report',
      ];

      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfExportService().exportKundliPdf(
                      Map<String, dynamic>.from(controller.kundliResult),
                    ),
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                label: Text(
                  'Download PDF Report',
                  style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF5D3012),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                ),
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                  ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  children: tabs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final title = entry.value;
                    final isSelected = controller.selectedTabIndex.value == idx;
                    return GestureDetector(
                      onTap: () => controller.selectedTabIndex.value = idx,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: isSelected
                                  ? Colors.brown
                                  : Colors.transparent,
                              width: 3.h,
                            ),
                          ),
                        ),
                        child: Text(
                          title,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: isSelected
                                ? Colors.brown
                                : Colors.grey.shade600,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Padding(padding: EdgeInsets.all(24.w), child: _buildTabContent()),
          ],
        ),
      ),
    ],
  );
});
}

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0:
          return _buildBasicDetailsTab();
        case 1:
          return _buildPlanetaryPositionTab();
        case 2:
          return _buildPredictionsTab();
        case 3:
          return _buildShodashvargaTab();
        case 4:
          return _buildAshtakvargaTab();
        case 5:
          return _buildMahadashaTab();
        case 6:
          return _buildYoginiDashaTab();
        case 7:
          return _buildDoshaTab();
        case 8:
          return _buildReportTab();
        default:
          return const SizedBox();
      }
    });
  }

  Widget _buildBasicDetailsTab() {
    final res = controller.kundliResult;
    final birthDetails = Map<String, dynamic>.from(
      res['basic_details'] ?? res['birth_details'] ?? res,
    );
    final panchangDetails = Map<String, dynamic>.from(
      res['panchang_details'] ?? res['panchang'] ?? {},
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 700) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildCardList(
                  'BIRTH DETAILS',
                  birthDetails,
                  _birthKeys,
                ),
              ),
              SizedBox(width: 24.w),
              Expanded(
                child: _buildCardList(
                  'PANCHANG DETAILS',
                  panchangDetails,
                  _panchangKeys,
                ),
              ),
            ],
          );
        } else {
          return Column(
            children: [
              _buildCardList('BIRTH DETAILS', birthDetails, _birthKeys),
              SizedBox(height: 24.h),
              _buildCardList(
                'PANCHANG DETAILS',
                panchangDetails,
                _panchangKeys,
              ),
            ],
          );
        }
      },
    );
  }

  final _birthKeys = [
    {'label': 'NAME', 'key': 'name'},
    {'label': 'BIRTH DATE', 'key': 'dob'},
    {'label': 'BIRTH TIME', 'key': 'tob'},
    {'label': 'PLACE OF BIRTH', 'key': 'place'},
    {'label': 'LATITUDE', 'key': 'lat'},
    {'label': 'LONGITUDE', 'key': 'lon'},
    {'label': 'TIMEZONE', 'key': 'tz'},
    {'label': 'RASI', 'key': 'rasi'},
    {'label': 'PDF LINK', 'key': 'pdf_link', 'isLink': true},
  ];

  final _panchangKeys = [
    {'label': 'TITHI', 'key': 'tithi'},
    {'label': 'YOGA', 'key': 'yoga'},
    {'label': 'KARANA', 'key': 'karana'},
    {'label': 'SUNRISE', 'key': 'sunrise'},
    {'label': 'SUNSET', 'key': 'sunset'},
    {'label': 'AYANAMSA', 'key': 'ayanamsa'},
    {'label': 'HORA', 'key': 'hora'},
    {'label': 'DAY LORD', 'key': 'day_lord'},
    {'label': 'DAY OF BIRTH', 'key': 'day_of_birth'},
  ];

  String _getStructuredValue(String title, String key, Map<String, dynamic> data) {
    dynamic rawVal = data[key];

    if (title == 'BIRTH DETAILS') {
      if (key == 'lat') {
        rawVal = data['lat'] ?? controller.lat;
      } else if (key == 'lon') {
        rawVal = data['lon'] ?? data['lng'] ?? controller.lon;
      } else if (key == 'tz') {
        rawVal = data['tz'] ?? data['timezone'] ?? '5.5';
      } else if (key == 'rasi') {
        rawVal = data['rasi'] ?? data['rashi'] ?? data['zodiac'] ?? controller.kundliResult['extra']?['rasi'];
        if (rawVal == null || rawVal.toString().isEmpty) {
          final planets = controller.kundliResult['planets'] as List? ?? [];
          if (planets.isNotEmpty) {
            final moon = planets.firstWhere((p) => p['name'] == 'Moon' || p['name'] == 'Sun', orElse: () => planets.first);
            rawVal = moon['rashi'] ?? moon['zodiac'];
          }
        }
      } else if (key == 'name') {
        rawVal = data['name'] ?? controller.kundliNameController.text;
      } else if (key == 'dob') {
        rawVal = data['dob'] ?? controller.kundliDobController.text;
      } else if (key == 'tob') {
        rawVal = data['tob'] ?? controller.kundliTobController.text;
      } else if (key == 'place') {
        rawVal = data['place'] ?? controller.kundliPlaceController.text;
      }
    }

    if (rawVal == null) return 'N/A';

    if (rawVal is Map) {
      final name = rawVal['name']?.toString() ?? rawVal['details']?.toString() ?? '';
      final type = rawVal['type']?.toString() ?? '';
      if (name.isNotEmpty && type.isNotEmpty) {
        return '$name ($type)';
      } else if (name.isNotEmpty) {
        return name;
      }
      final cleanParts = <String>[];
      rawVal.forEach((k, v) {
        if (k != 'meaning' && k != 'special' && k != 'diety' && v != null && v.toString().isNotEmpty) {
          cleanParts.add('$k: $v');
        }
      });
      return cleanParts.isNotEmpty ? cleanParts.join(', ') : 'N/A';
    }

    final str = rawVal.toString().trim();
    return str.isNotEmpty ? str : 'N/A';
  }

  Widget _buildCardList(
    String title,
    Map<String, dynamic> data,
    List<Map<String, dynamic>> structuredKeys,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: Center(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.green.shade800,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          ...structuredKeys.map((item) {
            final isLast = item == structuredKeys.last;
            return Column(
              children: [
                _buildDetailRow(
                  item['label'],
                  _getStructuredValue(title, item['key'], data),
                  isLink: item['isLink'] == true,
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    color: Colors.grey.shade100,
                    indent: 16.w,
                    endIndent: 16.w,
                  ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: isLink
                ? Row(
                    children: [
                      Icon(
                        Icons.check_circle_outline,
                        color: Colors.grey,
                        size: 16.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'View PDF Report',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  )
                : Text(
                    value,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.grey.shade700,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanetaryPositionTab() {
    final planets = controller.kundliResult['planets'] as List? ?? [];
    if (planets.isEmpty) return const Text('No planet data available');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: planets.length,
      itemBuilder: (context, index) {
        final p = planets[index];
        return Card(
          margin: EdgeInsets.only(bottom: 8.h),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ListTile(
            title: Text(
              p['name']?.toString() ?? '',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              'Rashi: ${p['rashi']} | Nakshatra: ${p['nakshatra']} | House: ${p['house']} | Degree: ${p['local_degree']}',
              style: AppTextStyles.bodySmall,
            ),
            trailing: p['is_retro'] == true
                ? const Chip(
                    label: Text('Retro'),
                    visualDensity: VisualDensity.compact,
                  )
                : null,
          ),
        );
      },
    );
  }

  Widget _buildPredictionsTab() {
    final predictions = controller.kundliResult['predictions'] as List? ?? [];
    if (predictions.isEmpty) return const Text('No predictions available');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: predictions.length,
      itemBuilder: (context, index) {
        final p = predictions[index];
        return Card(
          margin: EdgeInsets.only(bottom: 12.h),
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.brown.shade100),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p['house_full_name']?.toString() ?? 'House',
                  style: AppTextStyles.h4.copyWith(color: Colors.brown),
                ),
                SizedBox(height: 8.h),
                Text(
                  p['meaning']?.toString() ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  p['life_impact']?.toString() ?? '',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildShodashvargaTab() {
    final charts = controller.kundliResult['Shodashvarga'] as List? ?? [];
    if (charts.isEmpty) return const Text('No charts available');

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16.w,
            mainAxisSpacing: 16.h,
            childAspectRatio: 1,
          ),
          itemCount: charts.length,
          itemBuilder: (context, index) {
            final chart = charts[index];
            return Column(
              children: [
                Text(
                  chart['name']?.toString() ?? '',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: chart['svg'] != null
                        ? SvgPicture.string(
                            chart['svg'],
                            width: double.infinity,
                            height: double.infinity,
                          )
                        : const Placeholder(),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAshtakvargaTab() {
    final ashtakvargaData =
        controller.kundliResult['ashtakvarga']?['ashtakvarga'] as List? ?? [];
    if (ashtakvargaData.isEmpty)
      return const Text('No Astakvarga data available');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
          columns: [
            const DataColumn(
              label: Text(
                'Planet',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            ...[
              'Ar',
              'Ta',
              'Ge',
              'Ca',
              'Le',
              'Vi',
              'Li',
              'Sc',
              'Sa',
              'Cp',
              'Aq',
              'Pi',
            ].map(
              (e) => DataColumn(
                label: Text(
                  e,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const DataColumn(
              label: Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
          rows: ashtakvargaData.map((row) {
            return DataRow(
              cells: [
                DataCell(
                  Text(
                    row['planet']?.toString() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                ...[
                  'Ar',
                  'Ta',
                  'Ge',
                  'Ca',
                  'Le',
                  'Vi',
                  'Li',
                  'Sc',
                  'Sa',
                  'Cp',
                  'Aq',
                  'Pi',
                ].map((code) => DataCell(Text(row[code]?.toString() ?? ''))),
                DataCell(
                  Text(
                    row['Total']?.toString() ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMahadashaTab() {
    final mahadashas = controller.kundliResult['mahadasha'] as List? ?? [];
    if (mahadashas.isEmpty) return const Text('No Mahadasha data available');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: mahadashas.length,
      itemBuilder: (context, index) {
        final md = mahadashas[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Text(
              '${md['dasha_name']} Mahadasha',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${md['dasha_start_year']} to ${md['dasha_end_year']}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.brown),
            ),
            children: (md['antar_dasha'] as List? ?? []).map((ad) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 32.w, right: 16.w),
                title: Text(
                  '${ad['dasha']} Antardasha',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${ad['dasha_start']} to ${ad['dasha_end']}',
                  style: AppTextStyles.bodySmall,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildYoginiDashaTab() {
    final yogini = controller.kundliResult['yogini_dasha'] as List? ?? [];
    if (yogini.isEmpty) return const Text('No Yogini Dasha data available');

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: yogini.length,
      itemBuilder: (context, index) {
        final yd = yogini[index];
        return Card(
          elevation: 0,
          margin: EdgeInsets.only(bottom: 8.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: ExpansionTile(
            title: Text(
              '${yd['dasha']} Dasha',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(
              '${yd['start_date']} to ${yd['end_date']} | Lord: ${yd['lord']}',
              style: AppTextStyles.bodySmall.copyWith(color: Colors.brown),
            ),
            children: (yd['sub_dasha'] as List? ?? []).map((sub) {
              return ListTile(
                contentPadding: EdgeInsets.only(left: 32.w, right: 16.w),
                title: Text(
                  '${sub['dasha']} Sub-Dasha',
                  style: AppTextStyles.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  '${sub['start_date']} to ${sub['end_date']}',
                  style: AppTextStyles.bodySmall,
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildDoshaTab() {
    final dosha = controller.kundliResult['dosha'] as Map? ?? {};
    if (dosha.isEmpty) return const Text('No Dosha data available');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildDoshaCard('Mangal Dosha', dosha['mangal']),
        SizedBox(height: 16.h),
        _buildDoshaCard('Kaalsarp Dosha', dosha['kaalsarp']),
        SizedBox(height: 16.h),
        _buildDoshaCard('Pitra Dosha', dosha['pitra']),
      ],
    );
  }

  Widget _buildDoshaCard(String title, dynamic doshaData) {
    if (doshaData == null) return const SizedBox();

    final isPresent =
        doshaData['is_dosha_present'] == true ||
        doshaData['is_pitra_dosha_present'] == true ||
        doshaData['manglik_present'] == true ||
        doshaData['manglik_status'] == true;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isPresent ? Colors.red.shade50 : Colors.green.shade50,
        border: Border.all(
          color: isPresent ? Colors.red.shade200 : Colors.green.shade200,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isPresent ? Icons.warning_amber : Icons.check_circle_outline,
                color: isPresent ? Colors.red : Colors.green,
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isPresent
                      ? Colors.red.shade800
                      : Colors.green.shade800,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            doshaData['bot_response']?.toString() ?? doshaData.toString(),
            style: AppTextStyles.bodySmall.copyWith(
              color: isPresent ? Colors.red.shade900 : Colors.green.shade900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    final report = controller.kundliResult['report'] as Map? ?? {};
    if (report.isEmpty) return const Text('No report available');

    final ascendant = report['Ascendant Report'];
    final planetsMap = report['Planet Report'] as Map? ?? {};

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (ascendant != null) ...[
          Text(
            'Ascendant Report',
            style: AppTextStyles.h4.copyWith(color: Colors.brown),
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.brown.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              ascendant['report']?.toString() ?? ascendant.toString(),
              style: AppTextStyles.bodySmall.copyWith(
                height: 1.5,
                color: Colors.brown.shade900,
              ),
            ),
          ),
          SizedBox(height: 24.h),
        ],
        if (planetsMap.isNotEmpty) ...[
          Text('Planet Reports', style: AppTextStyles.h4),
          SizedBox(height: 8.h),
          ...planetsMap.entries.map((e) {
            return Card(
              elevation: 0,
              margin: EdgeInsets.only(bottom: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
                side: BorderSide(color: Colors.grey.shade200),
              ),
              child: ExpansionTile(
                title: Text(
                  e.key.toString(),
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      left: 16.w,
                      right: 16.w,
                      bottom: 16.h,
                    ),
                    child: Text(
                      e.value['report']?.toString() ?? e.value.toString(),
                      style: AppTextStyles.bodySmall.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ],
    );
  }
}
