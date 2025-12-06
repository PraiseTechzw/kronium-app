import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/settings_service.dart';
import 'package:kronium/core/supabase_service.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    print('Initializing Supabase...');
    await SupabaseService.instance.initialize();
    print('Supabase initialized successfully');
    
    // Register SupabaseService as a GetX dependency
    Get.put(SupabaseService.instance, permanent: true);

    // Initialize services
    print('Initializing UserController...');
    Get.put(UserController(), permanent: true);

    // Initialize authentication services
    print('Initializing UserAuthService...');
    Get.put(UserAuthService.instance, permanent: true);
    await UserAuthService.instance.initialize();

    print('Initializing AdminAuthService...');
    Get.put(AdminAuthService.instance, permanent: true);

    print('Initializing SettingsService...');
    Get.put(SettingsService());

    // Verify SettingsService is properly initialized
    try {
      Get.find<SettingsService>();
      print('SettingsService initialized successfully');
    } catch (e) {
      print('Error verifying SettingsService: $e');
    }

    print('All services initialized successfully');
    runApp(const KroniumProApp());
  } catch (e) {
    print('Error initializing app: $e');
    // Still run the app even if some services fail to initialize
    runApp(const KroniumProApp());
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
