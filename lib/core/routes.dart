import 'package:get/get.dart';
import 'package:kronium/pages/admin/admin_bookings_page.dart';
import 'package:kronium/pages/admin/admin_chat_page.dart';
import 'package:kronium/pages/admin/admin_dashboard_page.dart';
import 'package:kronium/pages/admin/admin_services_page.dart';
import 'package:kronium/pages/admin/admin_setup_page.dart';
import 'package:kronium/pages/auth/customer_login_page.dart';
import 'package:kronium/pages/auth/customer_register_page.dart';
import 'package:kronium/pages/customer/customer_chat_page.dart';
import 'package:kronium/pages/customer/customer_dashboard_page.dart';
import 'package:kronium/pages/customer/customer_profile_page.dart';
import 'package:kronium/pages/home/home_page.dart';
import 'package:kronium/pages/profile/profile_page.dart';
import 'package:kronium/pages/projects/project_history_page.dart';
import 'package:kronium/pages/projects/projects_page.dart';
import 'package:kronium/pages/services/add_services_page.dart';
import 'package:kronium/pages/services/services_page.dart';
import 'package:kronium/pages/splash/splash_page.dart';
import 'package:kronium/core/user_auth_service.dart';


class AppRoutes {
  // Route names
  static const String splash = '/';
  static const String customerLogin = '/customer-login';
  static const String customerRegister = '/customer-register';
  static const String customerDashboard = '/customer-dashboard';
  static const String customerProfile = '/customer-profile';
  static const String customerChat = '/customer-chat';
  static const String adminSetup = '/admin-setup';
  static const String adminDashboard = '/admin-dashboard';
  static const String adminServices = '/admin-services';
  static const String adminBookings = '/admin-bookings';
  static const String adminChat = '/admin-chat';
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectHistory = '/project-history';
  static const String services = '/services';
  static const String addService = '/add-service';
  static const String profile = '/profile';

  static List<GetPage> pages = [
    // Splash Page
    GetPage(
      name: splash,
      page: () => const SplashPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
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
      name: customerDashboard,
      page: () => const CustomerDashboardPage(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: customerProfile,
      page: () => const CustomerProfilePage(),
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
      name: adminServices,
      page: () => const AdminServicesPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminBookings,
      page: () => const AdminBookingsPage(),
      transition: Transition.cupertino,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: adminChat,
      page: () => const AdminChatPage(),
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
  ];

  // Helper to get initial route based on user role
  static String getInitialRoute() {
    switch (userController.role.value) {
      case 'admin':
        return adminDashboard;
      case 'customer':
        return customerDashboard;
      default:
        return home;
    }
  }
}