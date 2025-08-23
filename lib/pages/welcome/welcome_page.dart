import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/models/user_model.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _greeting = '';
  String _userName = '';
  String _userRole = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _getUserInfo();
    _startAnimations();

    // Listen for changes in user data
    _setupUserDataListener();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );
  }

  void _setupUserDataListener() {
    final userController = Get.find<UserController>();

    // Listen for changes in userName and update UI
    ever(userController.userName, (String userName) {
      if (mounted && userName.isNotEmpty) {
        setState(() {
          _userName = userName;
          _userRole = userController.role.value;
        });
        print('Welcome page: Username updated to: $userName');
      }
    });

    // Also listen for userProfile changes as a fallback
    ever(userController.userProfile, (User? profile) {
      if (mounted && profile != null && userController.userName.value.isEmpty) {
        setState(() {
          _userName = profile.name;
          _userRole = userController.role.value;
        });
        print('Welcome page: Username updated from profile: ${profile.name}');
      }
    });
  }

  void _getUserInfo() {
    // Get user data from userController
    final userController = Get.find<UserController>();
    if (userController.userName.value.isNotEmpty) {
      _userName = userController.userName.value;
      _userRole = userController.role.value;
    } else if (userController.userProfile.value != null) {
      _userName = userController.userProfile.value!.name;
      _userRole = userController.role.value;
    } else {
      _userName = 'User';
      _userRole = 'customer';
    }

    print('Welcome page: Initial username: $_userName');

    // Set greeting based on time of day
    final hour = DateTime.now().hour;
    if (hour < 12) {
      _greeting = 'GOOD MORNING';
    } else if (hour < 17) {
      _greeting = 'GOOD AFTERNOON';
    } else {
      _greeting = 'GOOD EVENING';
    }
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 300), () {
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _navigateForward() {
    // Always land on Home; users can reach Projects/Dashboard from tabs
    Get.offAllNamed(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top section with status bar area
            Container(height: 24, color: Colors.grey[100]),

            // Main content
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Kronium Logo
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withValues(alpha: 0.2),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset(
                          AppConstants.appLogo,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Greeting Text
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _greeting,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // User Name
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _userName.toUpperCase(),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Welcome back text
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        'Welcome back to KRONIUM',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Role-specific message
                  SlideTransition(
                    position: _slideAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Text(
                        _userRole == 'admin'
                            ? 'Manage your agricultural services platform'
                            : 'Discover innovative agricultural and construction solutions',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[500],
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom section with DXC Technology style logo
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Kronium branding
                  Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Icon(
                          Icons.eco,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KRONIUM',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  // Continue button
                  ElevatedButton(
                    onPressed: _navigateForward,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 8,
                      shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
