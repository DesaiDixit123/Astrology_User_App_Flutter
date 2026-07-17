import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import 'package:astrology_user/features/services/presentation/controllers/puja_controller.dart';
import 'package:astrology_user/features/services/data/models/puja_model.dart';
import './puja_list_page.dart';
import '../../../../config/routes/app_routes.dart';

class EPoojaPage extends StatefulWidget {
  const EPoojaPage({super.key});

  @override
  State<EPoojaPage> createState() => _EPoojaPageState();
}

class _EPoojaPageState extends State<EPoojaPage> {
  final controller = Get.find<PujaController>();
  final TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Divine Pujas',
          style: AppTextStyles.h2.copyWith(color: AppColors.primary),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history, color: AppColors.primary),
            onPressed: () => Get.toNamed(AppRoutes.pujaHistory),
          ),
          SizedBox(width: 10.w),
        ],
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.categories.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              final displayCategories = searchController.text.isEmpty
                  ? controller.categories
                  : controller.categories
                      .where((c) => c.name
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase()))
                      .toList();

              if (displayCategories.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.temple_hindu,
                          size: 64.sp, color: AppColors.textHint),
                      SizedBox(height: 16.h),
                      Text(
                        searchController.text.isEmpty
                            ? 'No categories available'
                            : 'No results found',
                        style: AppTextStyles.bodyLarge,
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () => controller.getPujaCategories(),
                child: GridView.builder(
                  padding: EdgeInsets.all(20.w),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 20.h,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: displayCategories.length,
                  itemBuilder: (context, index) {
                    final category = displayCategories[index];
                    return _buildCategoryCard(category);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(15.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (value) => setState(() {}),
          decoration: InputDecoration(
            hintText: 'Search for Pujas...',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.textHint),
            prefixIcon: Icon(Icons.search, color: AppColors.primary),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15.h),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(PujaCategory category) {
    return GestureDetector(
      onTap: () => Get.to(() => PujaListPage(category: category)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey[200]!, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
                child: Hero(
                  tag: category.id,
                  child: category.fullImageUrl.isNotEmpty
                      ? Image.network(category.fullImageUrl, fit: BoxFit.cover)
                      : Container(
                          color: AppColors.primary.withOpacity(0.05),
                          child: Icon(Icons.temple_hindu,
                              size: 40.sp, color: AppColors.primary),
                        ),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.vertical(bottom: Radius.circular(20.r)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.orange[50]!.withOpacity(0.3)
                    ],
                  ),
                ),
                child: Center(
                  child: Text(
                    category.name,
                    style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
