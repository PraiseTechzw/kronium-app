import 'package:get/get.dart';
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
import 'package:kronium/pages/support/knowledge_base_page.dart';

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
  static const String home = '/home';
  static const String projects = '/projects';
  static const String projectHistory = '/project-history';
  static const String services = '/services';
  static const String addService = '/add-service';
  static const String profile = '/profile';
  static const String projectsOverview = '/projects-overview';
  static const String knowledgeBase = '/knowledge-base';

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

    // Profile
    GetPage(
      name: profile,
      page: () => const ProfilePage(),
      transition: Transition.size,
      transitionDuration: const Duration(milliseconds: 800),
    ),
    GetPage(
      name: knowledgeBase,
      page: () => const KnowledgeBasePage(),
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
    // Backend removed - always show welcome page
    return welcome;
  }
}
