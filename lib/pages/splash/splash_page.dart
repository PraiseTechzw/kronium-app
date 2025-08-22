import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:lottie/lottie.dart';
import 'package:animate_do/animate_do.dart';

import 'package:shimmer/shimmer.dart';

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

    // Wait for both services to be initialized
    await Future.wait([
      userAuthService.isInitialized.stream.firstWhere((value) => value == true),
      adminAuthService.isInitialized.stream.firstWhere(
        (value) => value == true,
      ),
    ]);

    // Add a small delay for better UX
    await Future.delayed(const Duration(seconds: 2));

    // Navigate based on authentication status
    if (userAuthService.isLoggedIn) {
      Get.offAllNamed(AppRoutes.customerDashboard);
    } else if (adminAuthService.isAdmin) {
      Get.offAllNamed(AppRoutes.adminDashboard);
    } else {
      Get.offAllNamed(AppRoutes.customerRegister);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: Lottie.asset(
              AppConstants.splashAnimation,
              fit: BoxFit.cover,
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
                      color: Colors.white.withValues(alpha: 0.1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.asset(AppConstants.appLogo, height: 120),
                  ),
                ),
                const SizedBox(height: 30),
                Shimmer.fromColors(
                  baseColor: Colors.white,
                  highlightColor: Colors.yellow[100]!,
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
                        shadows: [
                          Shadow(
                            blurRadius: 10,
                            color: Colors.black.withValues(alpha: 0.2),
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
                      Lottie.asset(
                        AppConstants.loadingAnimation,
                        width: 150,
                        height: 150,
                      ),
                      const SizedBox(height: 20),
                      FadeInUp(
                        delay: const Duration(milliseconds: 1500),
                        child: Text(
                          'Welcome to Professional Services',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
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
