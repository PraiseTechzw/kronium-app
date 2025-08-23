import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/appwrite_client.dart';
import 'firebase_options.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');

    // Initialize services in the correct order with proper dependencies
    print('Initializing UserController...');
    Get.put(UserController(), permanent: true);

    print('Initializing UserAuthService...');
    Get.put(UserAuthService());

    print('Initializing AdminAuthService...');
    Get.put(AdminAuthService());

    print('Initializing FirebaseService...');
    Get.put(FirebaseService());

    print('Initializing AppwriteService...');
    AppwriteService.init();

    // Wait for authentication services to initialize and restore sessions
    print('Waiting for authentication services to initialize...');
    await _waitForAuthServices();

    print('All services initialized successfully');
    runApp(const KroniumProApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Still run the app even if some services fail to initialize
    runApp(const KroniumProApp());
  }
}

Future<void> _waitForAuthServices() async {
  try {
    final userAuthService = Get.find<UserAuthService>();
    final adminAuthService = Get.find<AdminAuthService>();

    // Wait for both services to be initialized with timeout
    await Future.wait([
      userAuthService.isInitialized.stream.firstWhere((value) => value == true),
      adminAuthService.isInitialized.stream.firstWhere(
        (value) => value == true,
      ),
    ]).timeout(const Duration(seconds: 15));

    // Additional delay to ensure user profile is loaded
    await Future.delayed(const Duration(milliseconds: 1000));

    // Validate and refresh the current session to ensure everything is synchronized
    print('Validating and refreshing user session...');
    await userAuthService.validateAndRefreshSession();

    // Check if user session was restored
    if (userAuthService.isUserLoggedIn.value) {
      print(
        'User session restored: ${userAuthService.userProfile.value?.name}',
      );
      print(
        'UserController userName: ${Get.find<UserController>().userName.value}',
      );
      print(
        'UserController userId: ${Get.find<UserController>().userId.value}',
      );
      print(
        'UserAuthService isLoggedIn: ${userAuthService.isUserLoggedIn.value}',
      );
    } else {
      print('No user session found');
    }
  } catch (e) {
    print('Timeout waiting for auth services, proceeding anyway: $e');
  }
}

class KroniumProApp extends StatelessWidget {
  const KroniumProApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.getInitialRoute(),
      getPages: AppRoutes.pages,
      defaultTransition: Transition.fadeIn,
    );
  }
}
