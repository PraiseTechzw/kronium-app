import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:animate_do/animate_do.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/widgets/login_bottom_sheet.dart';

class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({super.key});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = UserAuthService.instance.userProfile.value;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    } else {
      _nameController.text = '';
      _phoneController.text = '';
      _addressController.text = '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userAuthService = Get.find<UserAuthService>();
    await userAuthService.updateUserProfile({
      'name': _nameController.text.trim(),
      'phone': _phoneController.text.trim(),
      'address': _addressController.text.trim(),
    });

    setState(() {
      _isLoading = false;
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userAuthService = Get.find<UserAuthService>();
    final userController = Get.find<UserController>();
    final isLoggedIn = userController.role.value != 'guest';

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          Obx(() {
            final user = userAuthService.currentUserProfile;
            if (user == null) return const SizedBox.shrink();

            return IconButton(
              icon: Icon(_isEditing ? Iconsax.close_square : Iconsax.edit),
              onPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                  if (!_isEditing) {
                    _loadUserData(); // Reset to original values
                  }
                });
              },
              tooltip: _isEditing ? 'Cancel' : 'Edit',
            );
          }),
        ],
      ),
      body: Obx(() {
        final user = userAuthService.currentUserProfile;
        if (!isLoggedIn) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Iconsax.login, size: 60, color: Colors.orange),
                const SizedBox(height: 20),
                const Text(
                  'Please log in to view your profile.',
                  style: TextStyle(fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => showLoginBottomSheet(context),
                  child: const Text('Login'),
                ),
              ],
            ),
          );
        }
        if (user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Profile Header
                FadeInDown(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          AppTheme.primaryColor,
                          AppTheme.secondaryColor,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Profile Information
                FadeInUp(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Name Field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Full Name',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _nameController,
                                enabled: _isEditing,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.user),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: !_isEditing,
                                  fillColor:
                                      _isEditing ? null : Colors.grey[100],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your name';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Email Field (Read-only)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Email Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Iconsax.sms, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Text(
                                      user.email,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Phone Field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Phone Number',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneController,
                                enabled: _isEditing,
                                keyboardType: TextInputType.phone,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.call),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: !_isEditing,
                                  fillColor:
                                      _isEditing ? null : Colors.grey[100],
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your phone number';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),

                        const Divider(height: 1),

                        // Address Field
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Address',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _addressController,
                                enabled: _isEditing,
                                maxLines: 3,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Iconsax.location),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  filled: !_isEditing,
                                  fillColor:
                                      _isEditing ? null : Colors.grey[100],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Save Button (only when editing)
                if (_isEditing)
                  FadeInUp(
                    delay: const Duration(milliseconds: 200),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
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
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Account Actions
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(
                            Iconsax.shield_tick,
                            color: AppTheme.primaryColor,
                          ),
                          title: const Text('Change Password'),
                          trailing: const Icon(Iconsax.arrow_right_3),
                          onTap: () async {
                            // Show bottom sheet for change password
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              builder: (context) {
                                final passwordController =
                                    TextEditingController();
                                final confirmController =
                                    TextEditingController();
                                final formKey = GlobalKey<FormState>();
                                bool isLoading = false;
                                return StatefulBuilder(
                                  builder: (context, setState) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                        left: 24,
                                        right: 24,
                                        top: 24,
                                        bottom:
                                            MediaQuery.of(
                                              context,
                                            ).viewInsets.bottom +
                                            24,
                                      ),
                                      child: Form(
                                        key: formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Change Password',
                                              style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            TextFormField(
                                              controller: passwordController,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: 'New Password',
                                                prefixIcon: Icon(Iconsax.lock),
                                              ),
                                              validator: (value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a new password';
                                                }
                                                if (value.length < 6) {
                                                  return 'Password must be at least 6 characters';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 12),
                                            TextFormField(
                                              controller: confirmController,
                                              obscureText: true,
                                              decoration: const InputDecoration(
                                                labelText: 'Confirm Password',
                                                prefixIcon: Icon(Iconsax.lock),
                                              ),
                                              validator: (value) {
                                                if (value !=
                                                    passwordController.text) {
                                                  return 'Passwords do not match';
                                                }
                                                return null;
                                              },
                                            ),
                                            const SizedBox(height: 24),
                                            SizedBox(
                                              width: double.infinity,
                                              height: 48,
                                              child: ElevatedButton(
                                                onPressed:
                                                    isLoading
                                                        ? null
                                                        : () async {
                                                          if (formKey
                                                              .currentState!
                                                              .validate()) {
                                                            setState(
                                                              () =>
                                                                  isLoading =
                                                                      true,
                                                            );
                                                            final userAuthService =
                                                                Get.find<
                                                                  UserAuthService
                                                                >();
                                                            final success =
                                                                await userAuthService
                                                                    .changePassword(
                                                                      passwordController
                                                                          .text,
                                                                    );
                                                            setState(
                                                              () =>
                                                                  isLoading =
                                                                      false,
                                                            );
                                                            if (success) {
                                                              Navigator.pop(
                                                                context,
                                                              );
                                                            }
                                                          }
                                                        },
                                                child:
                                                    isLoading
                                                        ? const SizedBox(
                                                          width: 24,
                                                          height: 24,
                                                          child: CircularProgressIndicator(
                                                            strokeWidth: 2,
                                                            valueColor:
                                                                AlwaysStoppedAnimation<
                                                                  Color
                                                                >(Colors.white),
                                                          ),
                                                        )
                                                        : const Text(
                                                          'Update Password',
                                                        ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const Divider(height: 1),

                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            Iconsax.logout,
                            color: Colors.red,
                          ),
                          title: const Text(
                            'Logout',
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () async {
                            final userAuthService = Get.find<UserAuthService>();
                            await userAuthService.logout();
                            Get.offAllNamed(AppRoutes.customerLogin);
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      }),
    );
  }
}
