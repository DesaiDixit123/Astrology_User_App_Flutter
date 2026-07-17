import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:astrology_user/features/services/data/models/puja_model.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import './puja_details_page.dart';

class PujaListPage extends StatefulWidget {
  final PujaCategory category;

  const PujaListPage({super.key, required this.category});

  @override
  State<PujaListPage> createState() => _PujaListPageState();
}

class _PujaListPageState extends State<PujaListPage> {
  final controller = Get.find<PujaController>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.getPujaListByCategoryId(widget.category.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category.name),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.pujas.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.pujas.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined, size: 64.sp, color: AppColors.textHint),
                SizedBox(height: 16.h),
                const Text('No Pujas found in this category'),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.getPujaListByCategoryId(widget.category.id),
          child: ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: controller.pujas.length,
            itemBuilder: (context, index) {
              final puja = controller.pujas[index];
              return _buildPujaCard(puja);
            },
          ),
        );
      }),
    );
  }

  Widget _buildPujaCard(Puja puja) {
    return GestureDetector(
      onTap: () {
        Get.to(() => PujaDetailsPage(pujaId: puja.id));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100.w,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.horizontal(left: Radius.circular(20.r)),
                ),
                child: (puja.fullImageUrl.isNotEmpty)
                    ? ClipRRect(
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(20.r)),
                        child: Image.network(puja.fullImageUrl, fit: BoxFit.cover),
                      )
                    : Icon(Icons.temple_hindu, color: Colors.orange, size: 40.sp),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(12.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        puja.title,
                        style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        puja.subtitle,
                        style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.location_on_outlined, size: 14.sp, color: AppColors.textHint),
                              SizedBox(width: 4.w),
                              Text(puja.place, style: AppTextStyles.caption),
                            ],
                          ),
                          Icon(Icons.arrow_forward_ios, size: 14.sp, color: AppColors.primary),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
