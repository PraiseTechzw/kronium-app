import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:animate_do/animate_do.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthenticationAndNavigate();
  }

  Future<void> _checkAuthenticationAndNavigate() async {
    // Wait for authentication services to initialize
    final userAuthService = Get.find<UserAuthService>();
    final adminAuthService = Get.find<AdminAuthService>();

    print('Splash: Waiting for auth services to initialize...');

    try {
      // Wait for both services to be initialized with timeout
      await Future.wait([
        userAuthService.isInitialized.stream.firstWhere(
          (value) => value == true,
        ),
        adminAuthService.isInitialized.stream.firstWhere(
          (value) => value == true,
        ),
      ]).timeout(const Duration(seconds: 10));
    } catch (e) {
      print('Splash: Timeout waiting for auth services, proceeding anyway...');
    }

    print('Splash: Auth services initialized');
    print('Splash: User logged in: ${userAuthService.isLoggedIn}');
    print('Splash: Admin logged in: ${adminAuthService.isAdmin}');
    print('Splash: Admin isAdminLoggedIn: ${adminAuthService.isAdminLoggedIn.value}');
    print('Splash: Admin user: ${adminAuthService.adminUser.value?.email ?? "null"}');
    
    // Check SharedPreferences for admin session
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminEmail = prefs.getString('admin_email');
      print('Splash: Saved admin email: ${adminEmail ?? "null"}');
    } catch (e) {
      print('Splash: Error checking SharedPreferences: $e');
    }

    // Add a small delay for better UX
    await Future.delayed(const Duration(seconds: 2));

    // Navigate based on authentication status
    // Check admin status FIRST - admins should always go to admin interface
    if (adminAuthService.isAdmin) {
      print('Splash: Admin logged in, navigating to admin main page');
      Get.offAllNamed(AppRoutes.adminMain);
    } else if (userAuthService.isLoggedIn) {
      print('Splash: User already logged in, navigating to welcome page');
      Get.offAllNamed(AppRoutes.welcome);
    } else {
      print('Splash: No user logged in, navigating to customer register');
      Get.offAllNamed(AppRoutes.customerRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.white, Colors.grey[50]!, Colors.white],
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElasticIn(
                  duration: const Duration(milliseconds: 1800),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Image.asset(AppConstants.appLogo, height: 120),
                  ),
                ),
                const SizedBox(height: 30),
                Shimmer.fromColors(
                  baseColor: AppTheme.primaryColor,
                  highlightColor: AppTheme.secondaryColor,
                  period: const Duration(seconds: 2),
                  child: FadeInDown(
                    from: 50,
                    duration: const Duration(milliseconds: 1500),
                    child: Text(
                      AppConstants.appName,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                        color: AppTheme.primaryColor,
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.1),
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FadeInUp(
                  delay: const Duration(milliseconds: 1000),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 30,
                            height: 30,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1500),
                        child: Text(
                          'Welcome to Professional Services',
                          style: TextStyle(
                            color: AppTheme.primaryColor.withOpacity(0.8),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
