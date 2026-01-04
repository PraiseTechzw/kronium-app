import 'package:get/get.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/logger_service.dart';

/// Enhanced role management with permissions
class RoleManager {
  static final RoleManager _instance = RoleManager._internal();
  factory RoleManager() => _instance;
  RoleManager._internal();

  // Role definitions - Only customer and guest now
  static const String roleGuest = 'guest';
  static const String roleCustomer = 'customer';

  // Permission definitions - Customer focused
  static const String permissionViewServices = 'view_services';
  static const String permissionBookServices = 'book_services';
  static const String permissionManageProjects = 'manage_projects';
  static const String permissionViewDashboard = 'view_dashboard';
  static const String permissionViewAnalytics = 'view_analytics';

  // Role permissions mapping - Customer focused
  static const Map<String, List<String>> rolePermissions = {
    roleGuest: [permissionViewServices],
    roleCustomer: [
      permissionViewServices,
      permissionBookServices,
      permissionManageProjects,
      permissionViewDashboard,
      permissionViewAnalytics,
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

  /// Check if user can access admin features - Always false now
  bool canAccessAdmin() {
    return false; // No admin access in customer app
  }

  /// Check if user can access customer features
  bool canAccessCustomer() {
    return hasPermission(permissionBookServices) ||
        hasPermission(permissionManageProjects);
  }

  /// Validate role transition - Simplified for customer app
  bool canTransitionToRole(
    String fromRole,
    String toRole, {
    bool isAuthenticated = false,
  }) {
    // Allow staying in the same role (no transition needed)
    if (fromRole == toRole) {
      return true;
    }

    // Define allowed role transitions for customer app only
    const allowedTransitions = {
      roleGuest: [roleCustomer],
      roleCustomer: [roleGuest],
    };

    final allowed = allowedTransitions[fromRole] ?? [];
    final canTransition = allowed.contains(toRole);

    if (!canTransition) {
      logger.warning(
        'Role transition blocked: $fromRole -> $toRole (authenticated: $isAuthenticated)',
      );
    }

    return canTransition;
  }

  /// Get role display name
  String getRoleDisplayName(String role) {
    switch (role) {
      case roleGuest:
        return 'Guest';
      case roleCustomer:
        return 'Customer';
      default:
        return 'Unknown';
    }
  }

  /// Check if role is valid
  bool isValidRole(String role) {
    return rolePermissions.containsKey(role);
  }
}
