import 'package:get/get.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/logger_service.dart';

/// Enhanced role management with permissions
class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  // Role definitions
  static const String roleGuest = 'guest';
  static const String roleCustomer = 'customer';
  static const String roleAdmin = 'admin';
  static const String roleSuperAdmin = 'super_admin';

  // Permission definitions
  static const String permissionViewServices = 'view_services';
  static const String permissionBookServices = 'book_services';
  static const String permissionManageProjects = 'manage_projects';
  static const String permissionViewDashboard = 'view_dashboard';
  static const String permissionManageServices = 'manage_services';
  static const String permissionManageUsers = 'manage_users';
  static const String permissionManageBookings = 'manage_bookings';
  static const String permissionViewAnalytics = 'view_analytics';
  static const String permissionManageSystem = 'manage_system';

  // Role permissions mapping
  static const Map<String, List<String>> rolePermissions = {
    roleGuest: [permissionViewServices],
    roleCustomer: [
      permissionViewServices,
      permissionBookServices,
      permissionManageProjects,
      permissionViewDashboard,
    ],
    roleAdmin: [
      permissionViewServices,
      permissionBookServices,
      permissionManageProjects,
      permissionViewDashboard,
      permissionManageServices,
      permissionManageUsers,
      permissionManageBookings,
      permissionViewAnalytics,
    ],
    roleSuperAdmin: [
      permissionViewServices,
      permissionBookServices,
      permissionManageProjects,
      permissionViewDashboard,
      permissionManageServices,
      permissionManageUsers,
      permissionManageBookings,
      permissionViewAnalytics,
      permissionManageSystem,
    ],
  };

  /// Check if current user has specific permission
  bool hasPermission(String permission) {
    try {
      final userController = Get.find<UserController>();
      final currentRole = userController.role.value;

      final permissions = rolePermissions[currentRole] ?? [];
      final hasAccess = permissions.contains(permission);

      logger.debug(
        'Permission check: $permission for role $currentRole = $hasAccess',
      );
      return hasAccess;
    } catch (e) {
      logger.error('Error checking permission $permission', e);
      return false;
    }
  }

  /// Check if current user has any of the specified permissions
  bool hasAnyPermission(List<String> permissions) {
    return permissions.any((permission) => hasPermission(permission));
  }

  /// Check if current user has all specified permissions
  bool hasAllPermissions(List<String> permissions) {
    return permissions.every((permission) => hasPermission(permission));
  }

  /// Get all permissions for current user
  List<String> getCurrentUserPermissions() {
    try {
      final userController = Get.find<UserController>();
      final currentRole = userController.role.value;
      return rolePermissions[currentRole] ?? [];
    } catch (e) {
      logger.error('Error getting current user permissions', e);
      return [];
    }
  }

  /// Check if user can access admin features
  bool canAccessAdmin() {
    return hasPermission(permissionManageServices) ||
        hasPermission(permissionManageUsers) ||
        hasPermission(permissionManageBookings);
  }

  /// Check if user can access customer features
  bool canAccessCustomer() {
    return hasPermission(permissionBookServices) ||
        hasPermission(permissionManageProjects);
  }

  /// Validate role transition
  bool canTransitionToRole(String fromRole, String toRole) {
    // Define allowed role transitions
    const allowedTransitions = {
      roleGuest: [roleCustomer],
      roleCustomer: [roleGuest],
      roleAdmin: [roleGuest, roleCustomer],
      roleSuperAdmin: [roleGuest, roleCustomer, roleAdmin],
    };

    final allowed = allowedTransitions[fromRole] ?? [];
    return allowed.contains(toRole);
  }

  /// Get role display name
  String getRoleDisplayName(String role) {
    switch (role) {
      case roleGuest:
        return 'Guest';
      case roleCustomer:
        return 'Customer';
      case roleAdmin:
        return 'Administrator';
      case roleSuperAdmin:
        return 'Super Administrator';
      default:
        return 'Unknown';
    }
  }

  /// Check if role is valid
  bool isValidRole(String role) {
    return rolePermissions.containsKey(role);
  }
}
