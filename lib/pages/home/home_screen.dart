import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/pages/home/active_projects_section.dart';
import 'package:kronium/pages/home/featured_services_section.dart';
import 'package:kronium/pages/home/quick_actions_sections.dart';
import 'package:kronium/widgets/background_switcher.dart';
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

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 320.0, // Increased to prevent overflow
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
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  _buildHeaderRow(),
                  const SizedBox(height: 28),
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
      padding: const EdgeInsets.all(24),
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
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(35),
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
            child: Icon(Icons.engineering, color: Colors.white, size: 35),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.95),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Obx(() {
                  final userName =
                      userController.userName.value.isNotEmpty
                          ? userController.userName.value
                          : userController.userProfile.value?.name ?? 'User';
                  return Text(
                    userName,
                    style: TextStyle(
                      fontSize: 26,
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
                const SizedBox(height: 10),
                Obx(() {
                  final userId =
                      userController.userId.value.isNotEmpty
                          ? userController.userId.value
                          : userController.userProfile.value?.id ?? '';
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fingerprint, size: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'ID: ${userId.isNotEmpty ? userId : 'N/A'}',
                          style: TextStyle(
                            fontSize: 13,
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.secondaryColor.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(Icons.assignment_turned_in, color: Colors.white, size: 24),
                const SizedBox(height: 6),
                Text(
                  'Projects',
                  style: TextStyle(
                    fontSize: 11,
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
