import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/pages/home/active_projects_section.dart';
import 'package:kronium/pages/home/featured_services_section.dart';
import 'package:kronium/pages/home/quick_actions_sections.dart';
import 'package:kronium/widgets/background_switcher.dart';
import 'package:kronium/widgets/user_picker.dart';
import 'dart:async';

/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UserController userController;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();

    // Debug logging for username and ID
    print('HomeScreen: Initial username: ${userController.userName.value}');
    print('HomeScreen: Initial userId: ${userController.userId.value}');
    print(
      'HomeScreen: Initial userProfile: ${userController.userProfile.value?.name}',
    );

    // Listen for changes in user data
    _setupUserDataListener();

    // Load available users for selection
    _loadAvailableUsers();

    // Force refresh user data after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _refreshUserData();
    });

    // Set up periodic refresh timer
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        _refreshUserData();
      }
    });
  }

  void _setupUserDataListener() {
    // Listen for changes in userName and update UI
    ever(userController.userName, (String userName) {
      if (mounted && userName.isNotEmpty) {
        setState(() {});
        print('HomeScreen: Username updated to: $userName');
      }
    });

    // Listen for changes in userId and update UI
    ever(userController.userId, (String userId) {
      if (mounted && userId.isNotEmpty) {
        setState(() {});
        print('HomeScreen: UserId updated to: $userId');
      }
    });

    // Also listen for userProfile changes as a fallback
    ever(userController.userProfile, (profile) {
      if (mounted && profile != null) {
        setState(() {});
        print('HomeScreen: UserProfile updated to: ${profile.name}');
      }
    });
  }

  void _loadAvailableUsers() {
    try {
      final userAuthService = Get.find<UserAuthService>();
      // Try to load from Firestore first, fallback to sample data
      userAuthService.loadUsersFromFirestore();

      // Also add some immediate test users for quick testing
      _addImmediateTestUsers();
    } catch (e) {
      print('HomeScreen: Error loading available users: $e');
      // Fallback to immediate test users
      _addImmediateTestUsers();
    }
  }

  void _addImmediateTestUsers() {
    try {
      final testUsers = [
        User(
          id: 'test_001',
          name: 'Praise Masunga',
          email: 'praise@kronium.com',
          phone: '+1234567890',
          address: 'Kronium HQ',
          isActive: true,
        ),
        User(
          id: 'test_002',
          name: 'John Engineer',
          email: 'john@kronium.com',
          phone: '+0987654321',
          address: 'Engineering Dept',
          isActive: true,
        ),
      ];

      userController.setAvailableUsers(testUsers);
      print('HomeScreen: Added ${testUsers.length} immediate test users');
    } catch (e) {
      print('HomeScreen: Error adding immediate test users: $e');
    }
  }

  void _refreshUserData() {
    if (mounted) {
      print('HomeScreen: Refreshing user data...');
      print('HomeScreen: Current username: ${userController.userName.value}');
      print('HomeScreen: Current userId: ${userController.userId.value}');
      print(
        'HomeScreen: Current userProfile: ${userController.userProfile.value?.name}',
      );

      // Check if we need to re-find the UserController
      try {
        final currentUserController = Get.find<UserController>();
        if (currentUserController != userController) {
          print('HomeScreen: UserController changed, updating reference');
          userController = currentUserController;
        }
      } catch (e) {
        print('HomeScreen: Error finding UserController: $e');
      }

      // Try to get user data from UserAuthService if UserController is empty
      if (userController.userName.value.isEmpty &&
          userController.userId.value.isEmpty) {
        print(
          'HomeScreen: UserController is empty, trying to get data from UserAuthService',
        );
        try {
          final userAuthService = Get.find<UserAuthService>();
          if (userAuthService.currentUserProfile != null) {
            print(
              'HomeScreen: Found user profile in UserAuthService: ${userAuthService.currentUserProfile!.name}',
            );
            userController.setUserProfile(userAuthService.currentUserProfile);
          }
        } catch (e) {
          print('HomeScreen: Error finding UserAuthService: $e');
        }
      }

      // Force UI update
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh user data when dependencies change (e.g., when screen becomes visible)
    _refreshUserData();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundSwitcher(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddUserDialog,
          backgroundColor: AppTheme.secondaryColor,
          child: const Icon(Icons.person_add, color: Colors.white),
          tooltip: 'Add Test User',
        ),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),
                  const QuickActionsSection(),
                  const SizedBox(height: 24),
                  const FeaturedServicesSection(),
                  const SizedBox(height: 24),
                  const ActiveProjectsSection(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddUserDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add Test User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'Enter user name',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                hintText: 'Enter user email',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                hintText: 'Enter user phone',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  emailController.text.isNotEmpty) {
                final newUser = User(
                  id: 'user_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameController.text.trim(),
                  email: emailController.text.trim(),
                  phone: phoneController.text.trim(),
                  address: 'Test Address',
                  isActive: true,
                );

                try {
                  final userAuthService = Get.find<UserAuthService>();
                  userAuthService.addTestUser(newUser);
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Test user added successfully!',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                } catch (e) {
                  Get.snackbar(
                    'Error',
                    'Failed to add test user',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              }
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 280.0,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: AppTheme.primaryColor,
      collapsedHeight: 80.0,
      stretch: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.secondaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.9),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 16),
                  _buildUserInfoSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white.withValues(alpha: 0.25),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.4),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.shadow,
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.engineering, color: Colors.white, size: 28),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KRONIUM',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: AppTheme.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              ),
              Text(
                'Engineering Solutions',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoSection() {
    return Container(
      padding: const EdgeInsets.all(16), // Reduced padding
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadow,
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // User Picker
          const UserPicker(),
          const SizedBox(height: 12), // Reduced spacing
          // User Info Display
          Row(
            children: [
              Container(
                width: 60, // Reduced size
                height: 60, // Reduced size
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(30), // Reduced radius
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.shadow,
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.engineering,
                  color: Colors.white,
                  size: 30,
                ), // Reduced icon size
              ),
              const SizedBox(width: 16), // Reduced spacing
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back!',
                      style: TextStyle(
                        fontSize: 14, // Reduced font size
                        color: Colors.white.withValues(alpha: 0.95),
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 4), // Reduced spacing
                    Obx(() {
                      final userName =
                          userController.currentUserName.isNotEmpty
                              ? userController.currentUserName
                              : userController.userName.value.isNotEmpty
                              ? userController.userName.value
                              : userController.userProfile.value?.name ??
                                  'User';
                      return Text(
                        userName,
                        style: TextStyle(
                          fontSize: 22, // Reduced font size
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.8,
                          shadows: [
                            Shadow(
                              color: AppTheme.shadow,
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 8), // Reduced spacing
                    Obx(() {
                      final userId =
                          userController.currentUserId.isNotEmpty
                              ? userController.currentUserId
                              : userController.userId.value.isNotEmpty
                              ? userController.userId.value
                              : userController.userProfile.value?.id ?? '';
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // Reduced padding
                          vertical: 6, // Reduced padding
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            20,
                          ), // Reduced radius
                          border: Border.all(
                            color: AppTheme.secondaryColor.withValues(
                              alpha: 0.5,
                            ),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.fingerprint,
                              size: 14,
                              color: Colors.white,
                            ), // Reduced icon size
                            const SizedBox(width: 6), // Reduced spacing
                            Text(
                              'ID: ${userId.isNotEmpty ? userId : 'N/A'}',
                              style: TextStyle(
                                fontSize: 12, // Reduced font size
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12), // Reduced padding
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16), // Reduced radius
                  border: Border.all(
                    color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.assignment_turned_in,
                      color: Colors.white,
                      size: 20,
                    ), // Reduced icon size
                    const SizedBox(height: 4), // Reduced spacing
                    Text(
                      'Projects',
                      style: TextStyle(
                        fontSize: 10, // Reduced font size
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
