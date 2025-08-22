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
    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize services in the correct order
    Get.put(UserController(), permanent: true);
    Get.put(UserAuthService());
    Get.put(AdminAuthService());
    Get.put(FirebaseService());
    AppwriteService.init();

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
