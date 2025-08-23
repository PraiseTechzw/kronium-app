import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/routes.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  
  bool _isEditing = false;
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  bool _biometricEnabled = false;
  String _language = 'English';
  String _currency = 'USD';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = UserAuthService.instance.currentUserProfile;
    if (user != null) {
      _nameController.text = user.name;
      _emailController.text = user.email;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();
    final userAuthService = Get.find<UserAuthService>();

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
              child: const Icon(Iconsax.user, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'My Profile',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Iconsax.tick_circle : Iconsax.edit,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
                if (!_isEditing) {
                  _saveProfile();
                }
              });
            },
          ),
        ],
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
          children: [
            // Profile Header Section
            _buildProfileHeader(userController, userAuthService),
            const SizedBox(height: 30),

            // Profile Information Section
            _buildProfileInfoSection(),
            const SizedBox(height: 24),

            // Settings Section
            _buildSettingsSection(),
            const SizedBox(height: 24),

            // Account Actions Section
            _buildAccountActionsSection(userAuthService),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(
    UserController userController,
    UserAuthService userAuthService,
  ) {
    final user = userAuthService.currentUserProfile;
    return Center(
              child: Stack(
                children: [
                  Hero(
                    tag: 'profile-pic',
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
              child:
                  user?.name.isNotEmpty == true
                      ? Center(
                        child: Text(
                          user!.name[0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                        ),
                      )
                      : const Icon(Iconsax.user, size: 50, color: Colors.white),
                    ),
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: AppTheme.surfaceLight,
                          shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                        ),
                        child: const Icon(
                          Iconsax.camera,
                          color: AppTheme.primaryColor,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
    );
  }

  Widget _buildProfileInfoSection() {
    return FadeInUp(
      child: _buildSectionCard(
        title: 'Personal Information',
        icon: Iconsax.user,
                children: [
                  _profileField('Full Name', _nameController, Iconsax.user, _isEditing),
          _profileField('Email Address', _emailController, Iconsax.sms, false),
          _profileField(
            'Phone Number',
            _phoneController,
            Iconsax.call,
            _isEditing,
          ),
          _profileField(
            'Address',
            _addressController,
            Iconsax.location,
            _isEditing,
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: _buildSectionCard(
        title: 'Settings & Preferences',
        icon: Iconsax.setting,
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
      ),
    );
  }

  Widget _buildAccountActionsSection(UserAuthService userAuthService) {
    return FadeInUp(
      delay: const Duration(milliseconds: 400),
      child: _buildSectionCard(
        title: 'Account Actions',
        icon: Iconsax.user_edit,
        children: [
          _buildListTile(
            icon: Iconsax.lock,
            title: 'Change Password',
            subtitle: 'Update your account password',
            onTap: _showChangePasswordDialog,
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Iconsax.export,
            title: 'Export Data',
            subtitle: 'Download your personal data',
            onTap: _exportData,
          ),
          const Divider(height: 1),
          _buildListTile(
            icon: Iconsax.logout,
            title: 'Sign Out',
            subtitle: 'Sign out of your account',
            onTap: () => _signOut(userAuthService),
            textColor: AppTheme.primaryColor,
          ),
        ],
      ),
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

  Widget _profileField(
    String label,
    TextEditingController controller,
    IconData icon,
    bool enabled, {
    int maxLines = 1,
  }) {
    return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
            label,
                        style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
                      TextFormField(
            controller: controller,
            enabled: enabled,
            maxLines: maxLines,
                        decoration: InputDecoration(
              prefixIcon: Icon(icon, color: AppTheme.primaryColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
              filled: !enabled,
              fillColor: enabled ? null : Colors.grey[100],
            ),
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    try {
      final userAuthService = Get.find<UserAuthService>();
      await userAuthService.updateUserProfile({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      });

      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _showChangePasswordDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _ChangePasswordBottomSheet(),
    );
  }

  void _showLanguageDialog() {
    Get.snackbar(
      'Coming Soon',
      'Language selection will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _showCurrencyDialog() {
    Get.snackbar(
      'Coming Soon',
      'Currency selection will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _exportData() {
    Get.snackbar(
      'Coming Soon',
      'Data export will be available soon',
      backgroundColor: AppTheme.primaryColor,
      colorText: Colors.white,
    );
  }

  void _signOut(UserAuthService userAuthService) async {
    try {
      await userAuthService.logout();
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

class _ChangePasswordBottomSheet extends StatefulWidget {
  @override
  State<_ChangePasswordBottomSheet> createState() =>
      _ChangePasswordBottomSheetState();
}

class _ChangePasswordBottomSheetState
    extends State<_ChangePasswordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
          // Content
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              left: 24,
              right: 24,
              top: 16,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Iconsax.lock,
                          color: AppTheme.primaryColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  _buildPasswordField(
                    controller: _currentPasswordController,
                    label: 'Current Password',
                    icon: Iconsax.lock,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _newPasswordController,
                    label: 'New Password',
                    icon: Iconsax.lock_1,
                  ),
                  const SizedBox(height: 20),
                  _buildPasswordField(
                    controller: _confirmPasswordController,
                    label: 'Confirm New Password',
                    icon: Iconsax.lock_1,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _changePassword,
                          style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                              : const Text(
                                'Update Password',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
                  const SizedBox(height: 16),
          ],
        ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!, width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 20),
          ),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          if (label == 'Confirm New Password' &&
              value != _newPasswordController.text) {
            return 'Passwords do not match';
          }
          if (label == 'New Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  void _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final userAuthService = Get.find<UserAuthService>();
      final success = await userAuthService.changePassword(
        _newPasswordController.text,
      );

      if (success) {
        Navigator.pop(context);
        Get.snackbar(
          'Success',
          'Password updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update password: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
