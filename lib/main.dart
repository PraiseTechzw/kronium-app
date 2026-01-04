import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/constants.dart';
import 'package:kronium/core/routes.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/core/settings_service.dart';
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/core/logger_service.dart' as logging;
import 'package:kronium/core/role_manager.dart';
import 'package:kronium/core/api_service.dart';
import 'package:kronium/core/cache_service.dart';
import 'package:kronium/core/notification_service.dart';
import 'package:kronium/core/repository_service.dart';
import 'package:kronium/core/dashboard_controller.dart';
import 'package:kronium/core/toast_utils.dart';

void main() async {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  logging.logger.initialize(isProduction: false); // Set to true for production

  try {
    logging.logger.info('🚀 Starting Kronium Pro application...');

    // Initialize core services in order
    await _initializeCoreServices();

    // Initialize backend services
    await _initializeBackendServices();

    // Initialize business logic services
    await _initializeBusinessServices();

    logging.logger.info('✅ All services initialized successfully');

    // Show welcome toast after successful initialization
    Future.delayed(const Duration(milliseconds: 1500), () {
      ToastUtils.showSuccess(
        'Welcome to KRONIUM! 🚀\nYour agricultural & construction solution platform is ready!',
        title: 'App Ready',
        duration: const Duration(seconds: 4),
      );
    });

    runApp(const KroniumProApp());
  } catch (e, stackTrace) {
    logging.logger.fatal('💥 Critical error initializing app', e, stackTrace);
    // Still run the app even if some services fail to initialize
    runApp(const KroniumProApp());
  }
}

/// Initialize core services (database, auth, etc.)
Future<void> _initializeCoreServices() async {
  logging.logger.info('🔧 Initializing core services...');

  // Initialize Supabase (database)
  logging.logger.info('Initializing Supabase...');
  await SupabaseService.instance.initialize();
  Get.put(SupabaseService.instance, permanent: true);

  // Initialize role manager
  logging.logger.info('Initializing RoleManager...');
  Get.put(RoleManager(), permanent: true);

  // Initialize user controller
  logging.logger.info('Initializing UserController...');
  Get.put(UserController(), permanent: true);

  // Initialize authentication services
  logging.logger.info('Initializing UserAuthService...');
  Get.put(UserAuthService.instance, permanent: true);
  await UserAuthService.instance.initialize();

  logging.logger.info('Initializing SettingsService...');
  Get.put(SettingsService());

  // Verify SettingsService is properly initialized
  try {
    Get.find<SettingsService>();
    logging.logger.info('SettingsService initialized successfully');
  } catch (e) {
    logging.logger.error('Error verifying SettingsService', e);
  }

  logging.logger.info('✅ Core services initialized');
}

/// Initialize backend services (API, cache, notifications)
Future<void> _initializeBackendServices() async {
  logging.logger.info('🌐 Initializing backend services...');

  // Initialize API service
  logging.logger.info('Initializing ApiService...');
  final apiService = ApiService();
  apiService.initialize();
  Get.put(apiService, permanent: true);

  // Initialize cache service
  logging.logger.info('Initializing CacheService...');
  final cacheService = CacheService();
  await cacheService.initialize();
  Get.put(cacheService, permanent: true);

  // Initialize notification service
  logging.logger.info('Initializing NotificationService...');
  final notificationService = NotificationService();
  await notificationService.initialize();
  Get.put(notificationService, permanent: true);

  // Initialize repository manager
  logging.logger.info('Initializing RepositoryManager...');
  final repositoryManager = RepositoryManager();
  repositoryManager.initialize();
  Get.put(repositoryManager, permanent: true);

  logging.logger.info('✅ Backend services initialized');
}

/// Initialize business logic services (dashboard, etc.)
Future<void> _initializeBusinessServices() async {
  logging.logger.info('📊 Initializing business services...');

  // Initialize dashboard controller
  logging.logger.info('Initializing DashboardController...');
  Get.put(DashboardController(), permanent: true);

  logging.logger.info('✅ Business services initialized');
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
      // Add global error handling and responsive design
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0), // Fixed text scaling
          ),
          child: child!,
        );
      },
      // Global error handling
      unknownRoute: GetPage(
        name: '/404',
        page: () => const Scaffold(body: Center(child: Text('Page not found'))),
      ),
    );
  }
}
