import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/pages/home/active_projects_section.dart';
import 'package:kronium/pages/home/featured_services_section.dart';
import 'package:kronium/pages/home/quick_actions_sections.dart';
import 'package:kronium/widgets/background_switcher.dart';

/// Keep this widget focused and readable. Extend as needed.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final UserController userController;
  late final UserAuthService userAuthService;

  @override
  void initState() {
    super.initState();
    userController = Get.find<UserController>();
    userAuthService = Get.find<UserAuthService>();

    // Ensure UserController is synchronized with UserAuthService
    _syncUserData();

    // Force a refresh of user data if the service is already initialized
    if (userAuthService.isInitialized.value) {
      _refreshUserData();
    }

    // Validate and refresh the current session to ensure everything is synchronized
    print('HomeScreen: Validating and refreshing session...');
    userAuthService.validateAndRefreshSession();

    // Ensure user has a simple ID
    _ensureUserHasSimpleId();
  }

  Future<void> _ensureUserHasSimpleId() async {
    try {
      // Wait a bit for the user profile to load
      await Future.delayed(const Duration(seconds: 1));

      // Check if user has a simple ID
      final userProfile = userAuthService.userProfile.value;
      if (userProfile != null &&
          (userProfile.simpleId == null || userProfile.simpleId!.isEmpty)) {
        print('HomeScreen: User missing simple ID, generating one...');
        await userAuthService.forceGenerateSimpleId();
      }
    } catch (e) {
      print('HomeScreen: Error ensuring simple ID: $e');
    }
  }

  void _syncUserData() {
    print('HomeScreen: Setting up data synchronization...');

    // Listen for changes in UserAuthService and sync with UserController
    ever(userAuthService.userProfile, (profile) {
      print(
        'HomeScreen: UserAuthService userProfile changed: ${profile?.name ?? "null"}',
      );
      if (profile != null && mounted) {
        // Update UserController with the latest profile data
        userController.setUserProfile(profile);
        setState(() {});
      }
    });

    // Listen for UserAuthService initialization
    ever(userAuthService.isInitialized, (initialized) {
      print('HomeScreen: UserAuthService isInitialized changed: $initialized');
      if (initialized && mounted) {
        _refreshUserData();
      }
    });

    // Also listen for UserController changes
    ever(userController.userProfile, (profile) {
      print(
        'HomeScreen: UserController userProfile changed: ${profile?.name ?? "null"}',
      );
      if (mounted) {
        setState(() {});
      }
    });
  }

  void _refreshUserData() {
    print('HomeScreen: Refreshing user data...');

    // If UserAuthService has user data but UserController doesn't, sync them
    if (userAuthService.userProfile.value != null &&
        userController.userProfile.value == null) {
      print('HomeScreen: Syncing UserController with UserAuthService data');
      userController.setUserProfile(userAuthService.userProfile.value);
    }

    // If UserController has user data but UserAuthService doesn't, sync them
    if (userController.userProfile.value != null &&
        userAuthService.userProfile.value == null) {
      print('HomeScreen: Syncing UserAuthService with UserController data');
      userAuthService.userProfile.value = userController.userProfile.value;
    }

    // Print current state after refresh
    print(
      'HomeScreen: After refresh - UserAuthService: ${userAuthService.userProfile.value?.name ?? "null"}',
    );
    print(
      'HomeScreen: After refresh - UserController: ${userController.userProfile.value?.name ?? "null"}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundSwitcher(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Sliver App Bar with original design
            SliverAppBar(
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
              actions: [],
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 20),

                  const FeaturedServicesSection(),
                  const SizedBox(height: 24),
                  ActiveProjectsSection(),
                  const SizedBox(height: 24),
                  const QuickActionsSection(),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        // Logo and Branding
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
        // Brand Text
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
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
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(30),
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
            child: Icon(Icons.engineering, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  // Get user name from multiple sources with priority
                  String userName = '';
                  String userSimpleId = '';

                  // First try UserAuthService directly (most reliable)
                  if (userAuthService.userProfile.value?.name != null) {
                    userName = userAuthService.userProfile.value!.name;
                    userSimpleId =
                        userAuthService.userProfile.value!.simpleId ?? '';
                  }
                  // Then try UserController
                  else if (userController.userName.value.isNotEmpty) {
                    userName = userController.userName.value;
                    userSimpleId = userController.userSimpleId.value;
                  }
                  // Then try UserController userProfile
                  else if (userController.userProfile.value?.name != null) {
                    userName = userController.userProfile.value!.name;
                    userSimpleId =
                        userController.userProfile.value!.simpleId ?? '';
                  }

                  // Fallback to 'User' if still empty
                  if (userName.isEmpty) {
                    userName = 'User';
                  }

                  // Debug logging for simple ID
                  print('HomeScreen: userSimpleId = "$userSimpleId"');
                  print(
                    'HomeScreen: userAuthService.userProfile.value?.simpleId = "${userAuthService.userProfile.value?.simpleId}"',
                  );
                  print(
                    'HomeScreen: userController.userSimpleId.value = "${userController.userSimpleId.value}"',
                  );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: TextStyle(
                          fontSize: 22,
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
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'ID: ${userSimpleId.isNotEmpty ? userSimpleId : 'ABC23456'}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.white, size: 20),
                const SizedBox(height: 4),
                Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 10,
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
    );
  }
}
