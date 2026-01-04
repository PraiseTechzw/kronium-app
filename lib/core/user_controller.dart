import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/role_manager.dart';

/// Enhanced user controller with role management and validation
class UserController extends GetxController {
  RxString role = RoleManager.roleGuest.obs;
  RxString userId = ''.obs;
  RxString userSimpleId = ''.obs; // Sequential ID like AAA00001
  RxString userName = ''.obs;
  RxString userEmail = ''.obs;
  RxString userPhone = ''.obs;
  Rx<User?> userProfile = Rx<User?>(null);
  RxBool isLoading = false.obs;
  RxString lastError = ''.obs;

  final RoleManager _roleManager = RoleManager();

  @override
  void onInit() {
    super.onInit();
    logger.info('UserController initialized');
    _setupRoleListener();
  }

  void _setupRoleListener() {
    // Listen to role changes and validate permissions
    ever(role, (String newRole) {
      logger.info('Role changed to: $newRole');
      _validateRoleTransition(newRole);
    });
  }

  void _validateRoleTransition(String newRole) {
    if (!_roleManager.isValidRole(newRole)) {
      logger.warning('Invalid role attempted: $newRole');
      role.value = RoleManager.roleGuest;
      return;
    }

    logger.info(
      'Role transition validated: ${_roleManager.getRoleDisplayName(newRole)}',
    );
  }

  /// Set user role with validation
  void setRole(String newRole) {
    if (!_roleManager.isValidRole(newRole)) {
      logger.error('Attempted to set invalid role: $newRole');
      return;
    }

    final currentRole = role.value;
    if (!_roleManager.canTransitionToRole(currentRole, newRole)) {
      logger.warning('Invalid role transition from $currentRole to $newRole');
      return;
    }

    logger.info('Setting role from $currentRole to $newRole');
    role.value = newRole;
  }

  /// Set user information with validation
  void setUser(
    String id,
    String name,
    String newRole, {
    String? simpleId,
    String? email,
    String? phone,
  }) {
    if (id.isEmpty || name.isEmpty) {
      logger.error('Cannot set user with empty ID or name');
      lastError.value = 'Invalid user data';
      return;
    }

    logger.info(
      'Setting user - ID: $id, SimpleID: $simpleId, Name: $name, Role: $newRole',
    );

    userId.value = id;
    userSimpleId.value = simpleId ?? '';
    userName.value = name;
    userEmail.value = email ?? '';
    userPhone.value = phone ?? '';
    setRole(newRole);

    lastError.value = '';
  }

  /// Enhanced logout with cleanup
  void logout() {
    logger.info('Logging out user: ${userName.value}');

    userId.value = '';
    userSimpleId.value = '';
    userName.value = '';
    userEmail.value = '';
    userPhone.value = '';
    role.value = RoleManager.roleGuest;
    userProfile.value = null;
    isLoading.value = false;
    lastError.value = '';

    logger.info('User logged out successfully');
  }

  /// Set user profile with enhanced validation
  void setUserProfile(User? profile) {
    if (profile == null) {
      logger.warning('Attempted to set null user profile');
      userProfile.value = null;
      return;
    }

    logger.info('Setting user profile for: ${profile.name}');
    logger.debug(
      'Profile details - SimpleID: "${profile.simpleId}", Email: ${profile.email}',
    );

    userProfile.value = profile;
    userId.value = profile.id ?? '';
    userSimpleId.value = profile.simpleId ?? '';
    userName.value = profile.name;
    userEmail.value = profile.email;
    userPhone.value = profile.phone;

    // Set role if provided in profile
    if (profile.role != null && profile.role!.isNotEmpty) {
      setRole(profile.role!);
    }

    logger.info('User profile updated successfully');
  }

  /// Get display ID (simple ID if available, otherwise user ID)
  String get displayId =>
      userSimpleId.value.isNotEmpty ? userSimpleId.value : userId.value;

  /// Check if user is properly loaded
  bool get isUserLoaded => userId.value.isNotEmpty && userName.value.isNotEmpty;

  /// Check if user is authenticated (not guest)
  bool get isAuthenticated =>
      role.value != RoleManager.roleGuest && isUserLoaded;

  /// Check if user is admin
  bool get isAdmin => _roleManager.canAccessAdmin();

  /// Check if user is customer
  bool get isCustomer => _roleManager.canAccessCustomer();

  /// Check if user has specific permission
  bool hasPermission(String permission) =>
      _roleManager.hasPermission(permission);

  /// Get user's role display name
  String get roleDisplayName => _roleManager.getRoleDisplayName(role.value);

  /// Get current user state for debugging
  Map<String, dynamic> getCurrentState() {
    return {
      'userId': userId.value,
      'userSimpleId': userSimpleId.value,
      'userName': userName.value,
      'userEmail': userEmail.value,
      'role': role.value,
      'roleDisplayName': roleDisplayName,
      'isAuthenticated': isAuthenticated,
      'isAdmin': isAdmin,
      'isCustomer': isCustomer,
      'isLoading': isLoading.value,
      'lastError': lastError.value,
      'permissions': _roleManager.getCurrentUserPermissions(),
    };
  }

  /// Print current state for debugging
  void debugCurrentState() {
    final state = getCurrentState();
    logger.debug('UserController Current State: $state');
  }

  /// Validate user session
  bool validateSession() {
    if (!isAuthenticated) {
      logger.warning('Invalid session: User not authenticated');
      return false;
    }

    if (userProfile.value == null) {
      logger.warning('Invalid session: User profile not loaded');
      return false;
    }

    logger.debug('Session validated successfully');
    return true;
  }

  /// Handle authentication error
  void handleAuthError(String error) {
    logger.error('Authentication error: $error');
    lastError.value = error;
    logout();
  }

  /// Set loading state
  void setLoading(bool loading) {
    isLoading.value = loading;
  }
}
