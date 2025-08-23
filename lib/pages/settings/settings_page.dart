import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/routes.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserController _userController = Get.find<UserController>();
  final UserAuthService _userAuthService = Get.find<UserAuthService>();

  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _language = 'English';
  String _currency = 'USD';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Iconsax.setting_2,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Settings',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.arrow_left_2,
              color: Colors.white,
              size: 20,
            ),
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(),
            const SizedBox(height: 24),
            _buildAppearanceSection(),
            const SizedBox(height: 24),
            _buildPreferencesSection(),
            const SizedBox(height: 24),
            _buildSecuritySection(),
            const SizedBox(height: 24),
            _buildSupportSection(),
            const SizedBox(height: 24),
            _buildAccountSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return _buildSectionCard(
      title: 'Profile',
      icon: Iconsax.user,
      children: [
        _buildProfileTile(),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.edit,
          title: 'Edit Profile',
          subtitle: 'Update your personal information',
          onTap: () => Get.toNamed('/customer-profile'),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.lock,
          title: 'Change Password',
          subtitle: 'Update your account password',
          onTap: _showChangePasswordDialog,
        ),
      ],
    );
  }

  Widget _buildProfileTile() {
    final user = _userAuthService.currentUserProfile;
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(Iconsax.user, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.name ?? 'Guest User',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? 'guest@example.com',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(
                      _userController.role.value,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRoleColor(
                        _userController.role.value,
                      ).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _userController.role.value.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _getRoleColor(_userController.role.value),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return _buildSectionCard(
      title: 'Appearance',
      icon: Iconsax.colorfilter,
      children: [
        _buildListTile(
          icon: Iconsax.moon,
          title: 'Dark Mode',
          subtitle: 'Switch between light and dark themes',
          trailing: Switch(
            value: _isDarkMode,
            onChanged: (value) {
              setState(() {
                _isDarkMode = value;
              });
              // TODO: Implement dark mode toggle
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.global,
          title: 'Language',
          subtitle: _language,
          onTap: _showLanguageDialog,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.dollar_circle,
          title: 'Currency',
          subtitle: _currency,
          onTap: _showCurrencyDialog,
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return _buildSectionCard(
      title: 'Preferences',
      icon: Iconsax.setting,
      children: [
        _buildListTile(
          icon: Iconsax.notification,
          title: 'Notifications',
          subtitle: 'Manage your notification preferences',
          trailing: Switch(
            value: _notificationsEnabled,
            onChanged: (value) {
              setState(() {
                _notificationsEnabled = value;
              });
              // TODO: Implement notification toggle
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.finger_cricle,
          title: 'Biometric Login',
          subtitle: 'Use fingerprint or face ID to login',
          trailing: Switch(
            value: _biometricEnabled,
            onChanged: (value) {
              setState(() {
                _biometricEnabled = value;
              });
              // TODO: Implement biometric toggle
            },
            activeColor: AppTheme.primaryColor,
          ),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.location,
          title: 'Location Services',
          subtitle: 'Allow access to your location',
          onTap: _showLocationSettings,
        ),
      ],
    );
  }

  Widget _buildSecuritySection() {
    return _buildSectionCard(
      title: 'Security',
      icon: Iconsax.shield_tick,
      children: [
        _buildListTile(
          icon: Iconsax.lock_1,
          title: 'Two-Factor Authentication',
          subtitle: 'Add an extra layer of security',
          onTap: _showTwoFactorDialog,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.key,
          title: 'App Lock',
          subtitle: 'Lock the app when not in use',
          onTap: _showAppLockDialog,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.shield_search,
          title: 'Privacy Settings',
          subtitle: 'Control your data and privacy',
          onTap: _showPrivacySettings,
        ),
      ],
    );
  }

  Widget _buildSupportSection() {
    return _buildSectionCard(
      title: 'Support & Help',
      icon: Iconsax.message_question,
      children: [
        _buildListTile(
          icon: Iconsax.message,
          title: 'Contact Support',
          subtitle: 'Get help from our support team',
          onTap: () => Get.toNamed('/customer-chat'),
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.book_1,
          title: 'Help Center',
          subtitle: 'Browse help articles and FAQs',
          onTap: _showHelpCenter,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.info_circle,
          title: 'About App',
          subtitle: 'Version 1.0.0',
          onTap: _showAboutDialog,
        ),
      ],
    );
  }

  Widget _buildAccountSection() {
    return _buildSectionCard(
      title: 'Account',
      icon: Iconsax.user_edit,
      children: [
        _buildListTile(
          icon: Iconsax.export,
          title: 'Export Data',
          subtitle: 'Download your personal data',
          onTap: _exportData,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.trash,
          title: 'Delete Account',
          subtitle: 'Permanently delete your account',
          onTap: _showDeleteAccountDialog,
          textColor: Colors.red,
        ),
        const Divider(height: 1),
        _buildListTile(
          icon: Iconsax.logout,
          title: 'Sign Out',
          subtitle: 'Sign out of your account',
          onTap: _signOut,
          textColor: AppTheme.primaryColor,
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: AppTheme.primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (textColor ?? AppTheme.primaryColor).withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: textColor ?? AppTheme.primaryColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textColor ?? Colors.black87,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
      ),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.orange;
      case 'customer':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // Dialog methods
  void _showChangePasswordDialog() {
    // TODO: Implement change password dialog
    Get.snackbar(
      'Coming Soon',
      'Change password functionality will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showLanguageDialog() {
    // TODO: Implement language selection dialog
    Get.snackbar(
      'Coming Soon',
      'Language selection will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showCurrencyDialog() {
    // TODO: Implement currency selection dialog
    Get.snackbar(
      'Coming Soon',
      'Currency selection will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showLocationSettings() {
    // TODO: Implement location settings
    Get.snackbar(
      'Coming Soon',
      'Location settings will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showTwoFactorDialog() {
    // TODO: Implement 2FA dialog
    Get.snackbar(
      'Coming Soon',
      'Two-factor authentication will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showAppLockDialog() {
    // TODO: Implement app lock dialog
    Get.snackbar(
      'Coming Soon',
      'App lock settings will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showPrivacySettings() {
    // TODO: Implement privacy settings
    Get.snackbar(
      'Coming Soon',
      'Privacy settings will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showHelpCenter() {
    // TODO: Implement help center
    Get.snackbar(
      'Coming Soon',
      'Help center will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showAboutDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('About Kronium'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.12.01'),
            SizedBox(height: 8),
            Text('© 2024 Kronium. All rights reserved.'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Close')),
        ],
      ),
    );
  }

  void _exportData() {
    // TODO: Implement data export
    Get.snackbar(
      'Coming Soon',
      'Data export will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showDeleteAccountDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              // TODO: Implement account deletion
              Get.snackbar(
                'Coming Soon',
                'Account deletion will be available soon',
                backgroundColor: AppTheme.primaryColor,
                colorText: Colors.white,
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _signOut() async {
    try {
      await _userAuthService.logout();
      Get.snackbar(
        'Success',
        'Signed out successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      // Navigate to welcome page after logout
      Get.offAllNamed(AppRoutes.welcome);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to sign out: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
