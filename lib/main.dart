import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/firebase_service.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/appwrite_client.dart';
import 'firebase_options.dart'; 

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize services
  Get.put(AdminAuthService());
  Get.put(UserAuthService());
  Get.put(FirebaseService());
  Get.put(UserController(), permanent: true);
  AppwriteService.init();
  
  runApp(const KroniumProApp());
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