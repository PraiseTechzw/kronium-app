import 'package:get/get.dart';
import 'package:kronium/pages/admin/admin_bookings_page.dart';
import 'package:kronium/pages/admin/admin_chat_page.dart';
import 'package:kronium/pages/admin/admin_dashboard_page.dart';
import 'package:kronium/pages/admin/admin_services_page.dart';
import 'package:kronium/pages/admin/admin_setup_page.dart';
import 'package:kronium/pages/auth/customer_login_page.dart';
import 'package:kronium/pages/auth/customer_register_page.dart';
import 'package:kronium/pages/auth/forgot_password_page.dart';
import 'package:kronium/pages/customer/customer_chat_page.dart';
import 'package:kronium/pages/customer/customer_dashboard_page.dart';
import 'package:kronium/pages/home/home_page.dart';
import 'package:kronium/pages/profile/profile_page.dart';
import 'package:kronium/pages/projects/project_history_page.dart';
import 'package:kronium/pages/projects/projects_page.dart';
import 'package:kronium/pages/services/add_services_page.dart';
import 'package:kronium/pages/services/services_page.dart';
import 'package:kronium/pages/splash/splash_page.dart';
import 'package:kronium/pages/welcome/welcome_page.dart';
import 'package:kronium/core/user_auth_service.dart';
import 'package:kronium/pages/admin/admin_add_service_page.dart';
import 'package:kronium/pages/admin/admin_projects_page.dart';
import 'package:kronium/pages/admin/admin_management_page.dart';
import 'package:kronium/pages/admin/admin_main_page.dart';
import 'package:kronium/core/admin_auth_service.dart';
import 'package:kronium/pages/settings/settings_page.dart';

class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String customerLogin = '/customer-login';
  static const String customerRegister = '/customer-register';
  static const String forgotPassword = '/forgot-password';
  static const String customerDashboard = '/customer-dashboard';
  static const String customerProfile = '/customer-profile';
  static const String customerChat = '/customer-chat';
  static const String adminSetup = '/admin-setup';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminMain = '/admin-main';
  static const String adminServices = '/admin-services';
  static const String adminBookings = '/admin-bookings';
  static const String adminChat = '/admin-chat';
  static const String adminAddService = '/admin-add-service';
  static const String adminProjects = '/admin-projects';
  static const String adminManagement = '/admin-management';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectHistory = '/project-history';
  static const String services = '/services';
  static const String addService = '/add-service';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String projectsOverview = '/projects-overview';

  static List<GetPage> pages = [
    // Splash Page
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Welcome Page
    GetPage(
      name: welcome,
      page: () => const WelcomePage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 1000),
    ),

    // Customer Auth Pages
    GetPage(
      name: customerLogin,
      page: () => const CustomerLoginPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: customerRegister,
      page: () => const CustomerRegisterPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: customerDashboard,
      page: () => const CustomerDashboardPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: customerProfile,
      page: () => const ProfilePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: customerChat,
      page: () => const CustomerChatPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Admin Pages
    GetPage(
      name: adminSetup,
      page: () => const AdminSetupPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 1000),
    ),
    GetPage(
      name: adminDashboard,
      page: () => const AdminDashboardPage(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminMain,
      page: () => const AdminMainPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminAddService,
      page: () => AdminAddServicePage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminProjects,
      page: () => const AdminProjectsPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminManagement,
      page: () => const AdminMainPage(initialTab: 1),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminServices,
      page: () => const AdminMainPage(initialTab: 2),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminBookings,
      page: () => const AdminMainPage(initialTab: 3),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminChat,
      page: () => const AdminMainPage(initialTab: 4),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Main App Pages (User-facing)
    GetPage(
      name: home,
      page: () => HomePage(),
      transition: Transition.zoom,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Project-related Pages
    GetPage(
      name: projects,
      page: () => const ProjectsPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: addService,
      page: () => const AddServicePage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: projectHistory,
      page: () => const ProjectHistoryPage(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Services Page
    GetPage(
      name: services,
      page: () => const ServicesPage(),
      transition: Transition.topLevel,
      transitionDuration: const Duration(milliseconds: 800),
    ),

    // Profile & Settings
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      transition: Transition.size,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: settings,
      page: () => const SettingsPage(),
      transition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 800),
    ),
  ];

  // Helper to get initial route based on user role
  static String getInitialRoute() {
    // Always start with splash screen to check authentication state
    // The splash screen will handle routing based on session status
    return splash;
  }

  // Helper to get the appropriate route after authentication check
  static String getAuthenticatedRoute() {
    final userAuthService = UserAuthService.instance;
    final adminAuthService = AdminAuthService.instance;

    // Wait for services to initialize
    if (!userAuthService.isInitialized.value ||
        !adminAuthService.isInitialized.value) {
      return splash;
    }

    // Check admin status FIRST - admins should always go to admin interface
    if (adminAuthService.isAdmin) {
      return adminMain;
    }
    
    // Check if regular user is authenticated
    if (userAuthService.isUserLoggedIn.value) {
      // For authenticated regular users, show welcome page first
      return welcome;
    } else {
      // For new/unauthenticated users, show the sign-up page first
      return customerRegister;
    }
  }
}
