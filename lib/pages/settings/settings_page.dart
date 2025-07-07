import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';


class SettingsPage extends StatelessWidget {
  final RxBool _notificationsEnabled = true.obs;
  final RxBool _darkModeEnabled = false.obs;
  final RxBool _biometricEnabled = false.obs;

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FadeInDown(
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _settingsItem(
                        'Notifications',
                        'Enable or disable app notifications',
                        Iconsax.notification,
                        Obx(() => Switch(
                          value: _notificationsEnabled.value,
                          onChanged: (value) => _notificationsEnabled.value = value,
                          activeColor: AppTheme.primaryColor,
                        )),
                      ),
                      const Divider(),
                      _settingsItem(
                        'Dark Mode',
                        'Switch between light and dark theme',
                        Iconsax.moon,
                        Obx(() => Switch(
                          value: _darkModeEnabled.value,
                          onChanged: (value) => _darkModeEnabled.value = value,
                          activeColor: AppTheme.primaryColor,
                        )),
                      ),
                      const Divider(),
                      _settingsItem(
                        'Biometric Login',
                        'Use fingerprint or face ID to login',
                        Iconsax.finger_cricle,
                        Obx(() => Switch(
                          value: _biometricEnabled.value,
                          onChanged: (value) => _biometricEnabled.value = value,
                          activeColor: AppTheme.primaryColor,
                        )),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _settingsActionItem(
                        'Privacy Policy',
                        Iconsax.document,
                        () {},
                      ),
                      const Divider(),
                      _settingsActionItem(
                        'Terms of Service',
                        Iconsax.document_text,
                        () {},
                      ),
                      const Divider(),
                      _settingsActionItem(
                        'Help & Support',
                        Iconsax.message_question,
                        () {},
                      ),
                      const Divider(),
                      _settingsActionItem(
                        'Rate the App',
                        Iconsax.star,
                        () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _settingsActionItem(
                        'About App',
                        Iconsax.info_circle,
                        () => _showAboutDialog(context),
                      ),
                      const Divider(),
                      _settingsActionItem(
                        'Back to Home',
                        Iconsax.home,
                        () => Get.offAllNamed(AppRoutes.home),
                        color: Colors.blue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _settingsItem(String title, String subtitle, IconData icon, Widget trailing) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
        ),
      ),
      trailing: trailing,
    );
  }
  
  Widget _settingsActionItem(String title, IconData icon, VoidCallback onTap, {Color? color}) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: (color ?? AppTheme.primaryColor).withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? AppTheme.primaryColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.grey[800],
        ),
      ),
      trailing: const Icon(Iconsax.arrow_right_3, size: 20),
      onTap: onTap,
    );
  }
  
  void _showAboutDialog(BuildContext context) {
    Get.dialog(
      ScaleTransition(
        scale: CurvedAnimation(
          parent: ModalRoute.of(context)!.animation!,
          curve: Curves.fastOutSlowIn,
        ),
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('About KRONIUM PRO'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(AppConstants.appLogo, height: 80),
              const SizedBox(height: 20),
              const Text(
                'Version ${AppConstants.appVersion}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'KRONIUM PRO is a professional project management app for construction and agricultural services.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '© 2025 KRONIUM Technologies',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}