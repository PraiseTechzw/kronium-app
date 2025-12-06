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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when page becomes visible
    _loadUserData();
    
    // Add listeners to track user input
    _nameController.addListener(() {
      print('User typing in name field: "${_nameController.text}"');
    });
    
    _phoneController.addListener(() {
      print('User typing in phone field: "${_phoneController.text}"');
    });
    
    _addressController.addListener(() {
      print('User typing in address field: "${_addressController.text}"');
    });
  }

  void _loadUserData() {
    final user = UserAuthService.instance.currentUserProfile;
    print(
      '_loadUserData: Getting user from UserAuthService.instance.currentUserProfile',
    );
    print(
      '_loadUserData: User data: ${user?.name}, ${user?.email}, ${user?.phone}',
    );
    print(
      '_loadUserData: UserAuthService.instance.userProfile.value: ${UserAuthService.instance.userProfile.value?.name}, ${UserAuthService.instance.userProfile.value?.phone}',
    );

    if (user != null) {
      print('_loadUserData: User is not null, updating controllers...');
      print(
        '_loadUserData: Current controller values - Name: ${_nameController.text}, Phone: ${_phoneController.text}',
      );

      // Only update controllers if the values are different to avoid unnecessary updates
      if (_nameController.text != user.name) {
        print(
          '_loadUserData: Updating name from "${_nameController.text}" to "${user.name}"',
        );
        _nameController.text = user.name;
      }
      if (_emailController.text != user.email) {
        print(
          '_loadUserData: Updating email from "${_emailController.text}" to "${user.email}"',
        );
        _emailController.text = user.email;
      }
      if (_phoneController.text != user.phone) {
        print(
          '_loadUserData: Updating phone from "${_phoneController.text}" to "${user.phone}"',
        );
        _phoneController.text = user.phone;
      }
      if (_addressController.text != (user.address ?? '')) {
        print(
          '_loadUserData: Updating address from "${_addressController.text}" to "${user.address ?? ''}"',
        );
        _addressController.text = user.address ?? '';
      }

      print(
        '_loadUserData: Final controller values - Name: ${_nameController.text}, Phone: ${_phoneController.text}',
      );

      // Force UI update
      setState(() {});
    } else {
      print('_loadUserData: User is null, clearing controllers');
      _nameController.text = '';
      _emailController.text = '';
      _phoneController.text = '';
      _addressController.text = '';

      // Force UI update
      setState(() {});
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
              print('Edit/Save button pressed. Current _isEditing: $_isEditing');
              setState(() {
                _isEditing = !_isEditing;
                print('After toggle, _isEditing is now: $_isEditing');
                if (!_isEditing) {
                  print('Switching to save mode, calling _saveProfile()');
                  _saveProfile();
                } else {
                  print('Switching to edit mode');
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
      body: Obx(() {
        final user = userAuthService.currentUserProfile;

        // Update controllers when user profile changes
        if (user != null) {
          _nameController.text = user.name;
          _emailController.text = user.email;
          _phoneController.text = user.phone;
          _addressController.text = user.address ?? '';
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Profile Header Section
              _buildProfileHeader(userController, userAuthService),
              const SizedBox(height: 30),

              // Profile Information Section
              _buildProfileInfoSection(),
              const SizedBox(height: 24),

              // Account Actions Section
              _buildAccountActionsSection(userAuthService),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildProfileHeader(
    UserController userController,
    UserAuthService userAuthService,
  ) {
    final user = userAuthService.currentUserProfile;
    return Center(
      child: Column(
        children: [
          Stack(
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
                          : const Icon(
                            Iconsax.user,
                            size: 50,
                            color: Colors.white,
                          ),
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
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 8),
                      ],
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
          const SizedBox(height: 16),
          Text(
            user?.name ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'user@example.com',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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

  Widget _buildAccountActionsSection(UserAuthService userAuthService) {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
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
            onChanged: (value) {
              print('TextFormField "$label" changed to: "$value"');
            },
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
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        barrierDismissible: false,
      );

      final userAuthService = Get.find<UserAuthService>();

      // Validate required fields
      if (_nameController.text.trim().isEmpty) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Name cannot be empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      if (_phoneController.text.trim().isEmpty) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Phone number cannot be empty',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validate phone number format (basic validation)
      if (_phoneController.text.trim().length < 10) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Please enter a valid phone number (at least 10 digits)',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Validate name length
      if (_nameController.text.trim().length < 2) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'Name must be at least 2 characters long',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Debug: Show what user has input in the fields
      print('=== PROFILE UPDATE DEBUG ===');
      print('User input in name field: "${_nameController.text}"');
      print('User input in phone field: "${_phoneController.text}"');
      print('User input in address field: "${_addressController.text}"');
      print('Trimmed name: "${_nameController.text.trim()}"');
      print('Trimmed phone: "${_phoneController.text.trim()}"');
      print('Trimmed address: "${_addressController.text.trim()}"');

      // Update profile data
      final updateData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
      };
      
      print('Data being sent to updateUserProfile: $updateData');
      print('=== END PROFILE UPDATE DEBUG ===');

      await userAuthService.updateUserProfile(updateData);
      print('Profile updated in database: $updateData');

      // Wait a moment for the local profile to be updated
      await Future.delayed(const Duration(milliseconds: 300));

      Get.back(); // Close loading dialog

      // Force refresh the user profile from the service
      final updatedUser = userAuthService.currentUserProfile;
      print('Profile page: Getting updated user profile...');
      print(
        'Profile page: Updated user profile: ${updatedUser?.name}, ${updatedUser?.phone}',
      );
      print(
        'Profile page: UserAuthService userProfile.value: ${userAuthService.userProfile.value?.name}, ${userAuthService.userProfile.value?.phone}',
      );

      // The updateUserProfile method already updates the local profile
      // So we just need to refresh our UI
      _loadUserData();

      // Show success message
      Get.snackbar(
        'Success',
        'Profile updated successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Exit edit mode
      setState(() {
        _isEditing = false;
      });
    } catch (e) {
      Get.back(); // Close loading dialog

      print('Profile update error: $e');

      String errorMessage = 'Failed to update profile';
      if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please make sure you are logged in and try again.';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again.';
      } else if (e.toString().contains('database')) {
        errorMessage = 'Database error. Please try again.';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
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

  void _exportData() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        barrierDismissible: false,
      );

      final userAuthService = Get.find<UserAuthService>();
      final user = userAuthService.currentUserProfile;

      if (user == null) {
        Get.back(); // Close loading dialog
        Get.snackbar(
          'Error',
          'No user data found to export',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Create user data summary
      final userData = {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'address': user.address ?? 'Not provided',
        'createdAt': user.createdAt?.toIso8601String() ?? 'Unknown',
        'lastUpdated': user.updatedAt?.toIso8601String() ?? 'Unknown',
        'exportDate': DateTime.now().toIso8601String(),
      };

      // In a real app, you would save this to a file or send it via email
      // For now, we'll show the data in a dialog
      Get.back(); // Close loading dialog

      Get.dialog(
        AlertDialog(
          title: const Text('Your Data'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Name: ${userData['name']}'),
                const SizedBox(height: 8),
                Text('Email: ${userData['email']}'),
                const SizedBox(height: 8),
                Text('Phone: ${userData['phone']}'),
                const SizedBox(height: 8),
                Text('Address: ${userData['address']}'),
                const SizedBox(height: 8),
                Text('Member Since: ${userData['createdAt']}'),
                const SizedBox(height: 8),
                Text('Last Updated: ${userData['lastUpdated']}'),
                const SizedBox(height: 16),
                const Text(
                  'Note: In a production app, this data would be exported to a file or sent via email.',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Get.back(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      Get.back(); // Close loading dialog
      Get.snackbar(
        'Error',
        'Failed to export data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _signOut(UserAuthService userAuthService) async {
    try {
      // Show confirmation dialog
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Sign Out'),
          content: const Text('Are you sure you want to sign out?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Sign Out'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
        barrierDismissible: false,
      );

      await userAuthService.logout();

      Get.back(); // Close loading dialog

      Get.snackbar(
        'Success',
        'Signed out successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      Get.offAllNamed(AppRoutes.welcome);
    } catch (e) {
      Get.back(); // Close loading dialog

      print('Sign out error: $e');

      Get.snackbar(
        'Error',
        'Failed to sign out. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.error, color: Colors.white),
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

      // Validate current password (basic check)
      if (_currentPasswordController.text.trim().isEmpty) {
        Get.snackbar(
          'Error',
          'Please enter your current password',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isLoading = false);
        return;
      }

      // Validate new password strength
      final newPassword = _newPasswordController.text.trim();
      if (newPassword.length < 6) {
        Get.snackbar(
          'Error',
          'New password must be at least 6 characters long',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
        setState(() => _isLoading = false);
        return;
      }

      final success = await userAuthService.changePassword(newPassword);

      if (success) {
        Navigator.pop(context);
        Get.snackbar(
          'Success',
          'Password updated successfully!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );

        // Clear form fields
        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        Get.snackbar(
          'Error',
          'Failed to update password. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          icon: const Icon(Icons.error, color: Colors.white),
        );
      }
    } catch (e) {
      print('Password change error: $e');

      String errorMessage = 'Failed to update password';
      if (e.toString().contains('requires-recent-login')) {
        errorMessage =
            'Please log out and log back in before changing your password';
      } else if (e.toString().contains('weak-password')) {
        errorMessage =
            'Password is too weak. Please choose a stronger password with at least 6 characters';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your internet connection and try again';
      } else if (e.toString().contains('timeout')) {
        errorMessage = 'Request timeout. Please try again';
      } else if (e.toString().contains('authentication')) {
        errorMessage = 'Authentication error. Please try again';
      }

      Get.snackbar(
        'Error',
        errorMessage,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
