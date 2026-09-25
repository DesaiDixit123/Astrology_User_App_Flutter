import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/services/pdf_export_service.dart';
import '../controllers/matchmaking_controller.dart';
import '../widgets/north_indian_chart.dart';

class MatchmakingPage extends GetView<MatchmakingController> {
  const MatchmakingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text('kundali_matching'.tr),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        controller: controller.mainScrollController,
        padding: EdgeInsets.only(bottom: 24.h + MediaQuery.of(context).padding.bottom),
        child: Column(
          children: [
             _buildHeaderMenu(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   Container(
                     padding: EdgeInsets.all(16.w),
                     decoration: BoxDecoration(
                       color: Colors.white,
                       borderRadius: BorderRadius.circular(16.r),
                       boxShadow: [
                         BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                       ],
                     ),
                     child: Column(
                       children: [
                         Text('enter_details'.tr, style: AppTextStyles.h4.copyWith(color: Colors.green)),
                         SizedBox(height: 16.h),
                         // Main layout for inputs
                         LayoutBuilder(
                           builder: (context, constraints) {
                             if (constraints.maxWidth > 600) {
                               return Row(
                                 crossAxisAlignment: CrossAxisAlignment.start,
                                 children: [
                                   Expanded(child: _buildBoyForm(context)),
                                   SizedBox(width: 24.w),
                                   Expanded(child: _buildGirlForm(context)),
                                 ],
                               );
                             } else {
                               return Column(
                                 children: [
                                   _buildBoyForm(context),
                                   Divider(height: 32.h, thickness: 1, color: AppColors.border),
                                   _buildGirlForm(context),
                                 ],
                               );
                             }
                           }
                         ),
                       ],
                     ),
                   ),
                   SizedBox(height: 24.h),
                   Obx(() => SizedBox(
                     width: double.infinity,
                     child: ElevatedButton(
                       onPressed: controller.isLoading.value ? null : () => controller.getMatchmaking(),
                       style: ElevatedButton.styleFrom(
                         backgroundColor: const Color(0xFF8B5CF6), // Purple from web design
                         padding: EdgeInsets.symmetric(vertical: 14.h),
                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)), // Pill shape
                       ),
                       child: controller.isLoading.value 
                           ? const CircularProgressIndicator(color: Colors.white)
                           : Text('match_kundali'.tr, style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                     ),
                   )),
                   SizedBox(height: 24.h),
                   Container(
                     key: controller.resultKey,
                     child: _buildResultTabs(),
                   ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoyForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.person_outline, color: Colors.blue, size: 20.sp),
            ),
            SizedBox(width: 8.w),
            Text("Boy's Details", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        SizedBox(height: 16.h),
        _buildTextField(label: 'Boy Name *', hint: 'Enter name', controller: controller.mNameController),
        SizedBox(height: 12.h),
        _buildTextField(
          label: 'Birth Date *',
          hint: 'dd/mm/yyyy',
          icon: Icons.calendar_today_outlined,
          controller: controller.mDobController,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.mDobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          }
        ),
        SizedBox(height: 12.h),
        Obx(() => _buildTextField(
          label: 'Birth Time *',
          hint: '--:-- (HH:MM)',
          icon: Icons.access_time,
          controller: controller.mTobController,
          isEnabled: !controller.mTimeUnknown.value,
          onTap: () async {
            if (controller.mTimeUnknown.value) return;
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
              if (picked != null) {
                controller.mTobController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              }
            }
          )),
        SizedBox(height: 8.h),
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.mTimeUnknown.value,
              onChanged: (val) => controller.mTimeUnknown.value = val ?? false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
            Text("Don't know birth time", style: AppTextStyles.bodySmall),
          ],
        ),
        SizedBox(height: 8.h),
        _buildPlaceAutocomplete(
          label: 'Place of Birth *',
          hint: 'Enter city',
          controller: controller.mPlaceController,
          onPlaceSelected: (lat, lon) {
             controller.mLat = lat;
             controller.mLon = lon;
          }
        ),
      ],
    );
  }

  Widget _buildGirlForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(color: Colors.pink.withValues(alpha: 0.1), shape: BoxShape.circle),
              child: Icon(Icons.person_outline, color: Colors.pink, size: 20.sp),
            ),
            SizedBox(width: 8.w),
            Text("Girl's Details", style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
          ],
        ),
        SizedBox(height: 16.h),
        _buildTextField(label: 'Girl Name *', hint: 'Enter name', controller: controller.fNameController),
        SizedBox(height: 12.h),
        _buildTextField(
          label: 'Birth Date *',
          hint: 'dd/mm/yyyy',
          icon: Icons.calendar_today_outlined,
          controller: controller.fDobController,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              controller.fDobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
            }
          }
        ),
        SizedBox(height: 12.h),
        Obx(() => _buildTextField(
          label: 'Birth Time *',
          hint: '--:-- (HH:MM)',
          icon: Icons.access_time,
          controller: controller.fTobController,
          isEnabled: !controller.fTimeUnknown.value,
          onTap: () async {
            if (controller.fTimeUnknown.value) return;
            final picked = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
              if (picked != null) {
                controller.fTobController.text = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
              }
            }
          )),
        SizedBox(height: 8.h),
        Row(
          children: [
            Obx(() => Checkbox(
              value: controller.fTimeUnknown.value,
              onChanged: (val) => controller.fTimeUnknown.value = val ?? false,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            )),
            Text("Don't know birth time", style: AppTextStyles.bodySmall),
          ],
        ),
        SizedBox(height: 8.h),
        _buildPlaceAutocomplete(
          label: 'Place of Birth *',
          hint: 'Enter city',
          controller: controller.fPlaceController,
          onPlaceSelected: (lat, lon) {
             controller.fLat = lat;
             controller.fLon = lon;
          }
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    IconData? icon,
    required TextEditingController controller,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 4.h),
        TextFormField(
          controller: controller,
          readOnly: onTap != null || !isEnabled,
          onTap: isEnabled ? onTap : null,
          enabled: isEnabled,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
            suffixIcon: icon != null ? Icon(icon, color: Colors.grey, size: 18.sp) : null,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            filled: true,
            fillColor: isEnabled ? const Color(0xFFF8F9FA) : Colors.grey.shade200,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
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
        Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
        SizedBox(height: 4.h),
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
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            if (controller.text.isNotEmpty && textEditingController.text.isEmpty) {
              textEditingController.text = controller.text;
            }
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
              onChanged: (val) {
                controller.text = val;
              },
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.textHint),
                suffixIcon: Icon(Icons.location_on_outlined, color: Colors.grey, size: 18.sp),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                filled: true,
                fillColor: const Color(0xFFF8F9FA),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide(color: Colors.grey.shade300)),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildResultTabs() {
    return Obx(() {
      if (controller.matchmakingResult.isEmpty) return const SizedBox.shrink();
      
      final tabs = ['BASIC DETAILS', 'DOSHA', 'PLANET DETAILS', 'LAGNA CHART'];
      
      return Column(
        children: [
          Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => PdfExportService().exportMatchmakingPdf(
                      Map<String, dynamic>.from(controller.matchmakingResult),
                    ),
                icon: const Icon(Icons.picture_as_pdf_rounded, color: Colors.white),
                label: Text(
                  'Download Matching PDF Report',
                  style: AppTextStyles.button.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                ),
              ),
            ),
          ),
          Container(
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: tabs.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final title = entry.value;
                  final isSelected = controller.selectedTabIndex.value == idx;
                  return GestureDetector(
                    onTap: () => controller.selectedTabIndex.value = idx,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: isSelected ? Colors.brown : Colors.transparent,
                            width: 2.h,
                          ),
                        ),
                      ),
                      child: Text(
                        title,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: isSelected ? Colors.brown : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          _buildTabContent(),
        ],
      );
    });
  }

  Widget _buildTabContent() {
    return Obx(() {
      switch (controller.selectedTabIndex.value) {
        case 0: return _buildBasicDetailsTab();
        case 1: return _buildDoshaTab();
        case 2: return _buildPlanetDetailsTab();
        case 3: return _buildLagnaChartTab();
        default: return const SizedBox();
      }
    });
  }

  Widget _buildBasicDetailsTab() {
    final res = controller.matchmakingResult;
    final payload = res['payload'] as Map<String, dynamic>? ?? {};
    final ashtakoot = (res['ashtakoot'] as Map?)?.cast<String, dynamic>() ?? {};
    final tara = (ashtakoot['tara'] as Map?)?.cast<String, dynamic>() ?? {};

    final boyDetails = Map<String, dynamic>.from(res['boy'] ?? res['boy_details'] ?? res['boy_astro_details'] ?? {});
    final girlDetails = Map<String, dynamic>.from(res['girl'] ?? res['girl_details'] ?? res['girl_astro_details'] ?? {});
    
    final recommendation = res['recommendation']?.toString() ?? 'Match analysis generated successfully';
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildDetailsCard(
                'MALE BIRTH DETAILS',
                Colors.green.shade50,
                boyDetails,
                fallbackName: payload['boy_name'] ?? controller.mNameController.text,
                fallbackDob: payload['boy_dob'] ?? controller.mDobController.text,
                fallbackTob: payload['boy_tob'] ?? controller.mTobController.text,
                fallbackPlace: payload['boy_place'] ?? controller.mPlaceController.text,
                fallbackNakshatra: tara['boy_star']?.toString() ?? tara['boy_nakshatra']?.toString() ?? tara['boy_tara']?.toString(),
                fallbackNakshatraPada: tara['boy_pada']?.toString(),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDetailsCard(
                'FEMALE BIRTH DETAILS',
                Colors.red.shade50,
                girlDetails,
                fallbackName: payload['girl_name'] ?? controller.fNameController.text,
                fallbackDob: payload['girl_dob'] ?? controller.fDobController.text,
                fallbackTob: payload['girl_tob'] ?? controller.fTobController.text,
                fallbackPlace: payload['girl_place'] ?? controller.fPlaceController.text,
                fallbackNakshatra: tara['girl_star']?.toString() ?? tara['girl_nakshatra']?.toString() ?? tara['girl_tara']?.toString(),
                fallbackNakshatraPada: tara['girl_pada']?.toString(),
              ),
            ),
          ],
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(color: Colors.brown.shade100, shape: BoxShape.circle),
                child: Icon(Icons.favorite, color: Colors.brown, size: 32.sp),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('MATCH ANALYSIS & REPORT', style: AppTextStyles.h3),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.only(left: 12.w),
                      decoration: const BoxDecoration(
                        border: Border(left: BorderSide(color: Colors.grey, width: 3))
                      ),
                      child: Text(recommendation, 
                        style: AppTextStyles.bodyMedium.copyWith(fontStyle: FontStyle.italic)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsCard(
    String title, 
    Color bgColor, 
    Map<String, dynamic> data, {
    String? fallbackName,
    String? fallbackDob,
    String? fallbackTob,
    String? fallbackPlace,
    String? fallbackNakshatra,
    String? fallbackNakshatraPada,
  }) {
    final name = (data['name']?.toString().isNotEmpty == true)
        ? data['name'].toString()
        : (fallbackName?.isNotEmpty == true ? fallbackName! : 'N/A');

    String dateTimeStr = 'N/A';
    if (data['dob_tob'] != null && data['dob_tob'].toString().trim().isNotEmpty) {
      dateTimeStr = data['dob_tob'].toString();
    } else {
      final dob = data['dob'] ?? data['date'] ?? fallbackDob ?? '';
      final tob = data['tob'] ?? data['time'] ?? fallbackTob ?? '';
      if (dob.toString().isNotEmpty || tob.toString().isNotEmpty) {
        dateTimeStr = '$dob $tob'.trim();
      }
    }
    if (dateTimeStr == 'null null' || dateTimeStr.trim().isEmpty) {
      dateTimeStr = 'N/A';
    }

    final place = (fallbackPlace?.isNotEmpty == true)
        ? fallbackPlace!
        : (data['birth_place'] ?? data['place'] ?? 'N/A');
    final rasi = data['janam_rashi'] ?? data['rasi'] ?? data['zodiac'] ?? data['rashi'] ?? 'N/A';
    final rasiLord = data['rashi_lord'] ?? data['rasi_lord'] ?? data['zodiac_lord'] ?? 'N/A';
    
    final nakshatraStr = data['nakshatra'] ?? data['star'] ?? fallbackNakshatra;
    final nakshatra = (nakshatraStr != null && nakshatraStr.toString().trim().isNotEmpty) ? nakshatraStr.toString() : 'N/A';
    
    final padaStr = data['nakshatra_pada'] ?? data['pada'] ?? fallbackNakshatraPada;
    final nakshatraPada = (padaStr != null && padaStr.toString().trim().isNotEmpty) ? padaStr.toString() : 'N/A';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.vertical(top: Radius.circular(16.r))),
            child: Center(child: Text(title, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold, color: Colors.green))),
          ),
          _buildDetailRow('NAME', name),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('DATE & TIME', dateTimeStr),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('PLACE OF BIRTH', place),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('RASI', rasi),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('RASI LORD', rasiLord),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('NAKSHATRA', nakshatra),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('NAKSHATRA PADA', nakshatraPada),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 2, child: Text(label, style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.bold))),
          Expanded(flex: 3, child: Text(value, style: AppTextStyles.bodySmall)),
        ],
      ),
    );
  }

  Widget _buildDoshaTab() {
    final res = controller.matchmakingResult;
    final ashtakoot = (res['ashtakoot'] as Map?)?.cast<String, dynamic>() ?? {};
    final manglik = (res['manglik'] as Map?)?.cast<String, dynamic>() ?? {};

    dynamic getVal(Map? map, String key) => map? [key] ?? map?['score'] ?? map?['received_points'] ?? map?['received'];

    final gunas = [
      {
        'attribute': 'Varna',
        'male': ashtakoot['varna']?['boy_varna']?.toString() ?? '-',
        'female': ashtakoot['varna']?['girl_varna']?.toString() ?? '-',
        'outOf': '1',
        'received': getVal(ashtakoot['varna'] as Map?, 'varna')?.toString() ?? '0',
        'area': ashtakoot['varna']?['description']?.toString() ?? 'Work / Refinement',
      },
      {
        'attribute': 'Vashya',
        'male': ashtakoot['vasya']?['boy_vasya']?.toString() ?? '-',
        'female': ashtakoot['vasya']?['girl_vasya']?.toString() ?? '-',
        'outOf': '2',
        'received': getVal(ashtakoot['vasya'] as Map?, 'vasya')?.toString() ?? '0',
        'area': ashtakoot['vasya']?['description']?.toString() ?? 'Dominance / Attraction',
      },
      {
        'attribute': 'Tara',
        'male': ashtakoot['tara']?['boy_tara']?.toString() ?? '-',
        'female': ashtakoot['tara']?['girl_tara']?.toString() ?? '-',
        'outOf': '3',
        'received': getVal(ashtakoot['tara'] as Map?, 'tara')?.toString() ?? '0',
        'area': ashtakoot['tara']?['description']?.toString() ?? 'Destiny / Health',
      },
      {
        'attribute': 'Yoni',
        'male': ashtakoot['yoni']?['boy_yoni']?.toString() ?? '-',
        'female': ashtakoot['yoni']?['girl_yoni']?.toString() ?? '-',
        'outOf': '4',
        'received': getVal(ashtakoot['yoni'] as Map?, 'yoni')?.toString() ?? '0',
        'area': ashtakoot['yoni']?['description']?.toString() ?? 'Intimacy / Compatibility',
      },
      {
        'attribute': 'Maitri',
        'male': ashtakoot['grahamaitri']?['boy_lord']?.toString() ?? '-',
        'female': ashtakoot['grahamaitri']?['girl_lord']?.toString() ?? '-',
        'outOf': '5',
        'received': getVal(ashtakoot['grahamaitri'] as Map?, 'grahamaitri')?.toString() ?? '0',
        'area': ashtakoot['grahamaitri']?['description']?.toString() ?? 'Friendship / Mental Affinity',
      },
      {
        'attribute': 'Gana',
        'male': ashtakoot['gana']?['boy_gana']?.toString() ?? ashtakoot['gan']?['boy_gan']?.toString() ?? '-',
        'female': ashtakoot['gana']?['girl_gana']?.toString() ?? ashtakoot['gan']?['girl_gan']?.toString() ?? '-',
        'outOf': '6',
        'received': (getVal(ashtakoot['gana'] as Map?, 'gana') ?? getVal(ashtakoot['gan'] as Map?, 'gan'))?.toString() ?? '0',
        'area': ashtakoot['gana']?['description']?.toString() ?? ashtakoot['gan']?['description']?.toString() ?? 'Temperament',
      },
      {
        'attribute': 'Bhakoot',
        'male': ashtakoot['bhakoot']?['boy_rasi_name']?.toString() ?? '-',
        'female': ashtakoot['bhakoot']?['girl_rasi_name']?.toString() ?? '-',
        'outOf': '7',
        'received': getVal(ashtakoot['bhakoot'] as Map?, 'bhakoot')?.toString() ?? '0',
        'area': ashtakoot['bhakoot']?['description']?.toString() ?? 'Love / Family Harmony',
      },
      {
        'attribute': 'Nadi',
        'male': ashtakoot['nadi']?['boy_nadi']?.toString() ?? '-',
        'female': ashtakoot['nadi']?['girl_nadi']?.toString() ?? '-',
        'outOf': '8',
        'received': getVal(ashtakoot['nadi'] as Map?, 'nadi')?.toString() ?? '0',
        'area': ashtakoot['nadi']?['description']?.toString() ?? 'Health & Genes / Progeny',
      },
    ];

    num totalRec = 0;
    for (final g in gunas) {
      totalRec += num.tryParse(g['received']!) ?? 0;
    }
    final scoreDisplay = ashtakoot['score']?.toString() ?? ashtakoot['total_score']?.toString() ?? totalRec.toString();
    final rajjuDosha = ashtakoot['rajju_dosha']?.toString() ?? 'No';
    final vedhaDosha = ashtakoot['vedha_dosha']?.toString() ?? 'No';
    final manglikMatch = ashtakoot['manglik_match']?.toString() ?? manglik['manglik_match']?.toString() ?? 'Yes';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("COUPLE MATCH SUMMARY", style: AppTextStyles.h4),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(child: _buildDoshaCard('Ashtakoot', '$scoreDisplay/36')),
            SizedBox(width: 8.w),
            Expanded(child: _buildDoshaCard('Rajjoo Dosha', rajjuDosha)),
            SizedBox(width: 8.w),
            Expanded(child: _buildDoshaCard('Vedha Dosha', vedhaDosha)),
            SizedBox(width: 8.w),
            Expanded(child: _buildDoshaCard('Manglik Match', manglikMatch)),
          ],
        ),
        SizedBox(height: 24.h),
        Text("ASHTAKOOT GUNAS BREAKDOWN", style: AppTextStyles.h4),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.brown.shade100),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
              columns: const [
                DataColumn(label: Text('Attribute')),
                DataColumn(label: Text('Male')),
                DataColumn(label: Text('Female')),
                DataColumn(label: Text('Out of')),
                DataColumn(label: Text('Received')),
                DataColumn(label: Text('Area Of Life')),
              ],
              rows: gunas.map((g) {
                return DataRow(cells: [
                  DataCell(Text(g['attribute']!, style: const TextStyle(fontWeight: FontWeight.bold))),
                  DataCell(Text(g['male']!)),
                  DataCell(Text(g['female']!)),
                  DataCell(Text(g['outOf']!)),
                  DataCell(Text(g['received']!, style: TextStyle(color: Colors.brown.shade800, fontWeight: FontWeight.bold))),
                  DataCell(Text(g['area']!)),
                ]);
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoshaCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(color: Colors.brown.shade100, shape: BoxShape.circle),
            child: Icon(Icons.stars, color: Colors.brown, size: 22.sp),
          ),
          SizedBox(height: 8.h),
          Text(title, style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp), textAlign: TextAlign.center),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildPlanetDetailsTab() {
    final res = controller.matchmakingResult;
    final planets = (res['planets'] as Map?)?.cast<String, dynamic>() ?? {};

    List parsePlanets(dynamic raw) {
      if (raw == null) return [];
      if (raw is List) return raw;
      if (raw is Map) {
        return [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
            .map((k) => raw[k] ?? raw[k.toString()])
            .where((p) => p != null)
            .toList();
      }
      return [];
    }

    final boyPlanets = parsePlanets(planets['boy']);
    final girlPlanets = parsePlanets(planets['girl']);

    final boyName = controller.mNameController.text.trim().toUpperCase();
    final girlName = controller.fNameController.text.trim().toUpperCase();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanetTable(boyName.isEmpty ? "BOY'S PLANET DETAILS" : "$boyName'S PLANET DETAILS", boyPlanets),
        SizedBox(height: 24.h),
        _buildPlanetTable(girlName.isEmpty ? "GIRL'S PLANET DETAILS" : "$girlName'S PLANET DETAILS", girlPlanets),
      ],
    );
  }

  Widget _buildPlanetTable(String title, List planetsData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.only(left: 8.w),
          decoration: const BoxDecoration(border: Border(left: BorderSide(color: Colors.brown, width: 4))),
          child: Text(title, style: AppTextStyles.h4),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
              columns: const [
                DataColumn(label: Text('Planet')),
                DataColumn(label: Text('Sign')),
                DataColumn(label: Text('Sign Lord')),
                DataColumn(label: Text('Degree')),
                DataColumn(label: Text('House')),
              ],
              rows: planetsData.isEmpty
                  ? [
                      const DataRow(cells: [
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                        DataCell(Text('-')),
                      ])
                    ]
                  : planetsData.map((p) {
                      final pMap = (p as Map).cast<String, dynamic>();
                      final name = pMap['full_name'] ?? pMap['name'] ?? 'Planet';
                      final sign = pMap['sign'] ?? pMap['rasi'] ?? '-';
                      final signLord = pMap['sign_lord'] ?? pMap['lord'] ?? '-';
                      final degree = pMap['normDegree']?.toString() ?? pMap['degree']?.toString() ?? '-';
                      final house = pMap['house']?.toString() ?? '-';
                      return DataRow(cells: [
                        DataCell(Text(name.toString(), style: const TextStyle(fontWeight: FontWeight.bold))),
                        DataCell(Text(sign.toString())),
                        DataCell(Text(signLord.toString())),
                        DataCell(Text(degree.toString())),
                        DataCell(Text(house.toString())),
                      ]);
                    }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLagnaChartTab() {
    final res = controller.matchmakingResult;
    final charts = (res['charts'] as Map?)?.cast<String, dynamic>() ?? {};

    Map<String, List<String>> parseHouses(dynamic rawChart) {
      if (rawChart == null) return {};
      final Map<String, List<String>> housesMap = {};
      if (rawChart is Map) {
        rawChart.forEach((key, val) {
          final houseStr = key.toString();
          if (val is List) {
            housesMap[houseStr] = val.map((e) => e.toString()).toList();
          } else if (val is Map) {
            final planetsInHouse = (val['planets'] as List?)?.map((e) => e.toString()).toList() ?? [];
            housesMap[houseStr] = planetsInHouse;
          }
        });
      }
      return housesMap;
    }

    final boyHouses = parseHouses(charts['boy'] ?? charts['boy_chart'] ?? charts['boy_lagna']);
    final girlHouses = parseHouses(charts['girl'] ?? charts['girl_chart'] ?? charts['girl_lagna']);

    final boyName = controller.mNameController.text.trim().toUpperCase();
    final girlName = controller.fNameController.text.trim().toUpperCase();

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildChartCard('BOY LAGNA CHART', boyName.isEmpty ? 'MALE' : boyName, boyHouses)),
            SizedBox(width: 16.w),
            Expanded(child: _buildChartCard('GIRL LAGNA CHART', girlName.isEmpty ? 'FEMALE' : girlName, girlHouses)),
          ],
        ),
      ],
    );
  }

  Widget _buildChartCard(String header, String name, Map<String, List<String>> houses) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            decoration: BoxDecoration(color: Colors.brown.shade50, borderRadius: BorderRadius.circular(12.r)),
            child: Text(header, style: AppTextStyles.bodySmall.copyWith(color: Colors.brown)),
          ),
          SizedBox(height: 12.h),
          Text(name, style: AppTextStyles.h4),
          SizedBox(height: 16.h),
          NorthIndianChart(houses: houses),
          SizedBox(height: 16.h),
        ],
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
            _buildMenuTab('free_janam_kundali'.tr, false, onTap: () => Get.offNamed('/kundli')),
            SizedBox(width: 12.w),
            _buildMenuTab('kundali_matching'.tr, true),
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
          border: isSelected ? null : Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
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
}
