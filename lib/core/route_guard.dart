import 'package:get/get.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/role_manager.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/routes.dart';

/// Production-ready route guard with role-based access control
class RouteGuard {
  static final RouteGuard _instance = RouteGuard._internal();
  factory RouteGuard() => _instance;
  RouteGuard._internal();

  /// Check if user can access a route
  static bool canAccessRoute(String routeName) {
    try {
      final userController = Get.find<UserController>();
      final currentRole = userController.role.value;

      logger.debug('Route access check: $routeName for role: $currentRole');

      // Public routes (accessible to all)
      if (_isPublicRoute(routeName)) {
        return true;
      }

      // Guest-only routes (only accessible when not authenticated)
      if (_isGuestOnlyRoute(routeName)) {
        return currentRole == RoleManager.roleGuest;
      }

      // Authentication required routes
      if (_isAuthRequiredRoute(routeName)) {
        return currentRole != RoleManager.roleGuest;
      }

      // Admin-only routes
      if (_isAdminOnlyRoute(routeName)) {
        return userController.isAdmin;
      }

      // Customer-only routes
      if (_isCustomerOnlyRoute(routeName)) {
        return userController.isCustomer;
      }

      // Default: allow access
      return true;
    } catch (e) {
      logger.error('Error checking route access for $routeName', e);
      return false;
    }
  }

  /// Navigate with route guard
  static Future<void> navigateTo(String routeName, {dynamic arguments}) async {
    try {
      if (!canAccessRoute(routeName)) {
        _handleAccessDenied(routeName);
        return;
      }

      logger.info('Navigating to: $routeName');

      if (arguments != null) {
        await Get.toNamed(routeName, arguments: arguments);
      } else {
        await Get.toNamed(routeName);
      }
    } catch (e) {
      logger.error('Error navigating to $routeName', e);
      ErrorHandler.handleError(e, context: 'Navigation');
    }
  }

  /// Navigate and replace with route guard
  static Future<void> navigateAndReplace(
    String routeName, {
    dynamic arguments,
  }) async {
    try {
      if (!canAccessRoute(routeName)) {
        _handleAccessDenied(routeName);
        return;
      }

      logger.info('Navigating and replacing to: $routeName');

      if (arguments != null) {
        await Get.offNamed(routeName, arguments: arguments);
      } else {
        await Get.offNamed(routeName);
      }
    } catch (e) {
      logger.error('Error navigating and replacing to $routeName', e);
      ErrorHandler.handleError(e, context: 'Navigation');
    }
  }

  /// Navigate and clear stack with route guard
  static Future<void> navigateAndClearStack(
    String routeName, {
    dynamic arguments,
  }) async {
    try {
      if (!canAccessRoute(routeName)) {
        _handleAccessDenied(routeName);
        return;
      }

      logger.info('Navigating and clearing stack to: $routeName');

      if (arguments != null) {
        await Get.offAllNamed(routeName, arguments: arguments);
      } else {
        await Get.offAllNamed(routeName);
      }
    } catch (e) {
      logger.error('Error navigating and clearing stack to $routeName', e);
      ErrorHandler.handleError(e, context: 'Navigation');
    }
  }

  /// Handle access denied
  static void _handleAccessDenied(String routeName) {
    final userController = Get.find<UserController>();
    final currentRole = userController.role.value;

    logger.warning('Access denied to $routeName for role: $currentRole');

    // Show appropriate error message
    if (currentRole == RoleManager.roleGuest) {
      ErrorHandler.showWarningSnackbar('Please log in to access this page');
      navigateAndReplace(AppRoutes.customerLogin);
    } else if (_isAdminOnlyRoute(routeName) && !userController.isAdmin) {
      ErrorHandler.showWarningSnackbar('Admin access required');
      _navigateToAppropriateHome();
    } else if (_isCustomerOnlyRoute(routeName) && !userController.isCustomer) {
      ErrorHandler.showWarningSnackbar('Customer access required');
      _navigateToAppropriateHome();
    } else {
      ErrorHandler.showWarningSnackbar('Access denied');
      _navigateToAppropriateHome();
    }
  }

  /// Navigate to appropriate home based on role
  static void _navigateToAppropriateHome() {
    final userController = Get.find<UserController>();

    if (userController.isAdmin) {
      navigateAndReplace(AppRoutes.adminDashboard);
    } else if (userController.isCustomer) {
      navigateAndReplace(AppRoutes.customerDashboard);
    } else {
      navigateAndReplace(AppRoutes.welcome);
    }
  }

  /// Check if route is public (accessible to all)
  static bool _isPublicRoute(String routeName) {
    const publicRoutes = [AppRoutes.splash, AppRoutes.welcome];
    return publicRoutes.contains(routeName);
  }

  /// Check if route is guest-only (only accessible when not authenticated)
  static bool _isGuestOnlyRoute(String routeName) {
    const guestOnlyRoutes = [
      AppRoutes.customerLogin,
      AppRoutes.customerRegister,
      AppRoutes.forgotPassword,
      AppRoutes.adminSetup,
    ];
    return guestOnlyRoutes.contains(routeName);
  }

  /// Check if route requires authentication
  static bool _isAuthRequiredRoute(String routeName) {
    const authRequiredRoutes = [AppRoutes.profile, AppRoutes.customerProfile];
    return authRequiredRoutes.contains(routeName);
  }

  /// Check if route is admin-only
  static bool _isAdminOnlyRoute(String routeName) {
    const adminOnlyRoutes = [
      AppRoutes.adminDashboard,
      AppRoutes.adminMain,
      AppRoutes.adminServices,
      AppRoutes.adminBookings,
      AppRoutes.adminChat,
      AppRoutes.adminAddService,
      AppRoutes.adminProjects,
      AppRoutes.adminManagement,
    ];
    return adminOnlyRoutes.contains(routeName);
  }

  /// Check if route is customer-only
  static bool _isCustomerOnlyRoute(String routeName) {
    const customerOnlyRoutes = [
      AppRoutes.customerDashboard,
      AppRoutes.customerChat,
    ];
    return customerOnlyRoutes.contains(routeName);
  }

  /// Get initial route based on user state
  static String getInitialRoute() {
    try {
      final userController = Get.find<UserController>();

      if (userController.isAuthenticated) {
        if (userController.isAdmin) {
          return AppRoutes.adminDashboard;
        } else if (userController.isCustomer) {
          return AppRoutes.customerDashboard;
        }
      }

      return AppRoutes.splash;
    } catch (e) {
      logger.error('Error determining initial route', e);
      return AppRoutes.splash;
    }
  }

  /// Validate current route access
  static void validateCurrentRoute() {
    try {
      final currentRoute = Get.currentRoute;

      if (!canAccessRoute(currentRoute)) {
        logger.warning('Current route access validation failed: $currentRoute');
        _handleAccessDenied(currentRoute);
      }
    } catch (e) {
      logger.error('Error validating current route', e);
    }
  }

  /// Get allowed routes for current user
  static List<String> getAllowedRoutes() {
    try {
      final userController = Get.find<UserController>();
      final currentRole = userController.role.value;

      List<String> allowedRoutes = [];

      // Add public routes
      allowedRoutes.addAll([AppRoutes.splash, AppRoutes.welcome]);

      if (currentRole == RoleManager.roleGuest) {
        // Guest can access login/register routes
        allowedRoutes.addAll([
          AppRoutes.customerLogin,
          AppRoutes.customerRegister,
          AppRoutes.forgotPassword,
          AppRoutes.adminSetup,
        ]);
      } else {
        // Authenticated users can access common routes
        allowedRoutes.addAll([
          AppRoutes.home,
          AppRoutes.services,
          AppRoutes.profile,
          AppRoutes.knowledgeBase,
        ]);

        if (userController.isAdmin) {
          // Admin routes
          allowedRoutes.addAll([
            AppRoutes.adminDashboard,
            AppRoutes.adminMain,
            AppRoutes.adminServices,
            AppRoutes.adminBookings,
            AppRoutes.adminChat,
            AppRoutes.adminAddService,
            AppRoutes.adminProjects,
            AppRoutes.adminManagement,
          ]);
        }

        if (userController.isCustomer) {
          // Customer routes
          allowedRoutes.addAll([
            AppRoutes.customerDashboard,
            AppRoutes.customerProfile,
            AppRoutes.customerChat,
            AppRoutes.projects,
            AppRoutes.projectHistory,
          ]);
        }
      }

      return allowedRoutes;
    } catch (e) {
      logger.error('Error getting allowed routes', e);
      return [AppRoutes.splash];
    }
  }
}
