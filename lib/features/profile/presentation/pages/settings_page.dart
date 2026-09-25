import 'package:astrology_user/config/routes/app_routes.dart';
import 'package:astrology_user/core/theme/app_colors.dart';
import 'package:astrology_user/core/constants/app_constants.dart';
import 'package:astrology_user/core/localization/app_language_controller.dart';
import 'package:astrology_user/core/theme/app_text_styles.dart';
import 'package:astrology_user/core/theme/app_theme_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AppLanguageController languageController =
      Get.find<AppLanguageController>();
  final AppThemeController themeController = Get.find<AppThemeController>();
  final ProfileController profileController = Get.find<ProfileController>();
  bool notificationsEnabled = true;
  bool emailNotifications = false;
  bool smsNotifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('settings'.tr)),
      body: ListView(
        children: [
          Divider(height: 1.h, color: AppColors.border),
          _buildSection('preferences'.tr),
          Obx(
            () => _buildListTile(
              'language'.tr,
              languageController.currentLanguageLabel,
              Icons.language,
              () => _showLanguageDialog(),
            ),
          ),
          Obx(
            () => _buildListTile(
              'theme'.tr,
              themeController.isDarkMode ? 'dark'.tr : 'light'.tr,
              themeController.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              () => _showThemeDialog(),
            ),
          ),
          Divider(height: 1.h, color: AppColors.border),
          _buildSection('account'.tr),
          _buildListTile(
            'delete_account'.tr,
            '',
            Icons.delete_outline,
            () => _confirmDeleteAccount(),
            isDestructive: true,
          ),
          Divider(height: 1.h, color: AppColors.border),
          _buildSection('about'.tr),
          _buildListTile(
            'terms_conditions'.tr,
            '',
            Icons.description_outlined,
            () => Get.toNamed(AppRoutes.terms),
          ),
          _buildListTile(
            'privacy_policy'.tr,
            '',
            Icons.privacy_tip_outlined,
            () => Get.toNamed(AppRoutes.privacyPolicy),
          ),
          _buildListTile(
            'app_version'.tr,
            AppConstants.appVersion,
            Icons.info_outline,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 24.h, 16.w, 8.h),
      child: Text(
        title,
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildListTile(
    String title,
    String trailing,
    IconData icon,
    VoidCallback? onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? Colors.red : AppColors.primary,
      ),
      title: Text(
        title,
        style: AppTextStyles.bodyMedium.copyWith(
          color: isDestructive ? Colors.red : AppColors.textPrimary,
        ),
      ),
      trailing: trailing.isNotEmpty
          ? Text(trailing, style: AppTextStyles.bodySmall)
          : onTap != null
          ? Icon(Icons.chevron_right, color: AppColors.textSecondary)
          : null,
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('select_language'.tr),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguageController.supportedLanguages.map((language) {
              final isSelected =
                  language.code == languageController.currentLanguageCode;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(language.label),
                trailing: isSelected
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await languageController.changeLanguage(language.code);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('theme'.tr),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.light_mode, color: Colors.orange),
                title: Text('light'.tr),
                trailing: !themeController.isDarkMode
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await themeController.setThemeMode(ThemeMode.light);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.dark_mode, color: Colors.purple),
                title: Text('dark'.tr),
                trailing: themeController.isDarkMode
                    ? Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () async {
                  await themeController.setThemeMode(ThemeMode.dark);
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('delete_account_title'.tr),
        content: Text('delete_account_confirmation'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              profileController.deleteAccount();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('delete'.tr),
          ),
        ],
      ),
    );
  }
}
