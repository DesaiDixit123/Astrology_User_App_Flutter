import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../wallet/presentation/controllers/wallet_controller.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(WalletController());

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('transactions_title'.tr),
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(text: 'all'.tr),
              Tab(text: 'credit'.tr),
              Tab(text: 'debit'.tr),
            ],
          ),
        ),
        body: Obx(() {
          if (controller.isLoading.value && controller.transactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final transactions = controller.transactions;

          return TabBarView(
            children: [
              _buildTransactionList(transactions),
              _buildTransactionList(
                transactions.where((t) => t['type'] == 'credit').toList(),
              ),
              _buildTransactionList(
                transactions.where((t) => t['type'] == 'debit').toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTransactionList(List transactions) {
    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long, size: 64.w, color: AppColors.textHint),
            SizedBox(height: 16.h),
            Text('no_transactions_found'.tr, style: AppTextStyles.bodyMedium),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => Get.find<WalletController>().refresh(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: transactions.length,
        itemBuilder: (context, index) {
          final transaction = transactions[index];
          return _buildTransactionCard(transaction);
        },
      ),
    );
  }

  Widget _buildTransactionCard(Map transaction) {
    final isCredit = transaction['type'] == 'credit';
    final amount = transaction['amount']?.toString() ?? '0';
    final description = transaction['description'] ?? 'Transaction';
    final date = transaction['date'] ?? ''; // Backend returns pre-formatted date
    final status = (transaction['status'] ?? 'success').toString().capitalizeFirst ?? 'Success';
    final id = (transaction['_id'] ?? transaction['id'] ?? '').toString();

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isCredit
                  ? AppColors.success.withValues(alpha: 0.1)
                  : AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppColors.success : AppColors.error,
              size: 20.w,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  description,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  date,
                  style: AppTextStyles.caption,
                ),
                if (id.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    'ID: ${id.length > 10 ? id.substring(id.length - 8).toUpperCase() : id}',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.textHint,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '-'}₹$amount',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isCredit ? AppColors.success : AppColors.error,
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: status.toLowerCase() == 'success'
                      ? AppColors.success.withValues(alpha: 0.1)
                      : AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  status,
                  style: AppTextStyles.caption.copyWith(
                    color: status.toLowerCase() == 'success'
                        ? AppColors.success
                        : AppColors.warning,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
