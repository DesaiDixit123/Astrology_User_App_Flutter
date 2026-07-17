import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
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
          onSelected: (option) async {
             controller.text = option['description'];
             final details = await this.controller.getPlaceDetails(option['place_id']);
             if (details != null) {
               onPlaceSelected(details['lat']!, details['lon']!);
             }
          },
          fieldViewBuilder: (context, textEditingController, focusNode, onFieldSubmitted) {
            return TextField(
              controller: textEditingController,
              focusNode: focusNode,
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
    final boyDetails = Map<String, dynamic>.from(res['boy'] ?? res['boy_details'] ?? {});
    final girlDetails = Map<String, dynamic>.from(res['girl'] ?? res['girl_details'] ?? {});
    
    final recommendation = res['recommendation']?.toString() ?? 'Match analysis generated successfully';
    
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDetailsCard('MALE BIRTH DETAILS', Colors.green.shade50, boyDetails)),
            SizedBox(width: 16.w),
            Expanded(child: _buildDetailsCard('FEMALE BIRTH DETAILS', Colors.red.shade50, girlDetails)),
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

  Widget _buildDetailsCard(String title, Color bgColor, Map<String, dynamic> data) {
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
          _buildDetailRow('NAME', data['name'] ?? 'N/A'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('DATE & TIME', '${data['dob']} ${data['tob']}'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('PLACE OF BIRTH', data['place'] ?? 'N/A'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('RASI', data['rasi'] ?? 'N/A'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('RASI LORD', data['rasi_lord'] ?? 'N/A'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('NAKSHATRA', data['nakshatra'] ?? 'N/A'),
          Divider(height: 1, color: Colors.grey.shade200),
          _buildDetailRow('NAKSHATRA PADA', data['nakshatra_pada'] ?? 'N/A'),
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
     final ashtakoot = res['ashtakoot'] ?? res['response']?['ashtakoot'] ?? {};
     final score = ashtakoot['received'] ?? res['score'] ?? '0';
     final total = ashtakoot['total'] ?? '36';
     final doshaElements = res['dosha'] ?? {};

     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text("Couple's basic details", style: AppTextStyles.h4),
         SizedBox(height: 16.h),
         Row(
           children: [
             Expanded(child: _buildDoshaCard('Ashtakoot', '$score/$total')),
             SizedBox(width: 8.w),
             Expanded(child: _buildDoshaCard('Rajjoo Dosha', doshaElements['rajjoo'] ?? 'No')),
             SizedBox(width: 8.w),
             Expanded(child: _buildDoshaCard('Vedha Dosha', doshaElements['vedha'] ?? 'No')),
             SizedBox(width: 8.w),
             Expanded(child: _buildDoshaCard('Manglik Match', doshaElements['manglik'] ?? 'Yes')),
           ],
         ),
         SizedBox(height: 24.h),
         Text("Match Ashtakoot Points", style: AppTextStyles.h4),
         SizedBox(height: 12.h),
         // Real app would render a Data Table here based on `ashtakoot['points']` list
         Container(
           padding: EdgeInsets.all(16.w),
           decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.brown.shade100)),
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
               rows: [
                 // Placeholder rows since exact structure is unknown
                 DataRow(cells: [DataCell(Text('Varna')), DataCell(Text('Kshatriya')), DataCell(Text('Brahmin')), DataCell(Text('1')), DataCell(Text('0', style: TextStyle(color: Colors.brown))), DataCell(Text('Work'))]),
                 DataRow(cells: [DataCell(Text('Vashya')), DataCell(Text('Chatushpada')), DataCell(Text('Keeta')), DataCell(Text('2')), DataCell(Text('1', style: TextStyle(color: Colors.brown))), DataCell(Text('Innate Giving'))]),
               ],
             ),
           ),
         ),
       ],
     );
  }

  Widget _buildDoshaCard(String title, String value) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h),
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
            child: Icon(Icons.stars, color: Colors.brown, size: 24.sp),
          ),
          SizedBox(height: 8.h),
          Text(title, style: AppTextStyles.bodySmall.copyWith(fontSize: 10.sp)),
          SizedBox(height: 4.h),
          Text(value, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPlanetDetailsTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPlanetTable("BOY'S PLANET DETAILS", []),
        SizedBox(height: 24.h),
        _buildPlanetTable("GIRL'S PLANET DETAILS", []),
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
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r), border: Border.all(color: Colors.grey.shade200)),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(Colors.orange.shade50),
              columns: const [
                DataColumn(label: Text('planets')),
                DataColumn(label: Text('Sign')),
                DataColumn(label: Text('Sign Lord')),
                DataColumn(label: Text('Degree')),
                DataColumn(label: Text('House')),
              ],
              rows: planetsData.isEmpty ? [
                const DataRow(cells: [DataCell(Text('ASCENDANT')), DataCell(Text('Gemini')), DataCell(Text('Mercury')), DataCell(Text('11.20')), DataCell(Text('1'))]),
                const DataRow(cells: [DataCell(Text('SUN')), DataCell(Text('Pisces')), DataCell(Text('Jupiter')), DataCell(Text('22.87')), DataCell(Text('10'))]),
              ] : planetsData.map((p) => DataRow(cells: [
                DataCell(Text(p['name'] ?? '')),
                DataCell(Text(p['sign'] ?? '')),
                DataCell(Text(p['sign_lord'] ?? '')),
                DataCell(Text(p['degree']?.toString() ?? '')),
                DataCell(Text(p['house']?.toString() ?? '')),
              ])).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLagnaChartTab() {
    final boyName = controller.mNameController.text.toUpperCase();
    final girlName = controller.fNameController.text.toUpperCase();
    
    // Mock house data if backend doesn't provide exact structure
    final boyHouses = { "1": ["As"], "2": ["Mo", "Sa"], "4": ["Ra"], "7": ["Su", "Ve"], "10": ["Ke"]};
    final girlHouses = { "1": ["As"], "7": ["Mo"], "12": ["Su", "Ma", "Sa"], "2": ["Me", "Ra"], "8": ["Ke"]};

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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMenuTab('free_janam_kundali'.tr, false, onTap: () => Get.offNamed('/kundli')),
          SizedBox(width: 16.w),
          _buildMenuTab('kundali_matching'.tr, true),
        ],
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
