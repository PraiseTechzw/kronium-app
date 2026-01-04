import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/supabase_service.dart';
import 'package:kronium/core/logger_service.dart';
import 'package:kronium/core/error_handler.dart';
import 'package:kronium/core/role_manager.dart';

/// Enhanced admin authentication service with proper error handling
class AdminAuthService {
  static final AdminAuthService instance = AdminAuthService._();
  AdminAuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseService get _supabaseService => SupabaseService.instance;

  bool get isAdminLoggedIn {
    final userController = Get.find<UserController>();
    return userController.isAdmin;
  }

  Future<Map<String, dynamic>> createAdminAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      logger.info('Creating admin account for: $email');

      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty || name.trim().isEmpty) {
        return {'success': false, 'message': 'All fields are required'};
      }

      // Create auth user
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {'name': name.trim(), 'role': RoleManager.roleAdmin},
      );

      if (response.user != null) {
        logger.info('Auth user created successfully: ${response.user!.id}');

        // Create admin user profile in users table
        try {
          final userController = Get.find<UserController>();
          await _supabaseService.addAdmin(response.user!.id, {
            'name': name.trim(),
            'email': email.trim(),
            'role': RoleManager.roleAdmin,
            'created_at': DateTime.now().toIso8601String(),
          });

          // Load admin profile
          final adminUser = await _supabaseService.getUserById(
            response.user!.id,
          );
          if (adminUser != null) {
            userController.setUserProfile(adminUser);
            logger.info('Admin profile loaded and set successfully');

            ErrorHandler.showSuccessSnackbar(
              'Admin account created successfully',
            );

            return {
              'success': true,
              'message': 'Admin account created successfully',
              'user': response.user,
            };
          } else {
            logger.error('Failed to load admin profile after creation');
            return {
              'success': false,
              'message': 'Admin account created but profile loading failed',
            };
          }
        } catch (e) {
          logger.error('Error creating admin profile', e);
          ErrorHandler.handleError(e, context: 'Admin profile creation');
          return {
            'success': false,
            'message':
                'Admin account created but profile creation failed: ${e.toString()}',
          };
        }
      } else {
        logger.error('Admin account creation failed: No user returned');
        return {
          'success': false,
          'message': 'Admin account creation failed: No user returned',
        };
      }
    } on AuthException catch (e) {
      logger.error('Auth exception during admin creation', e);
      ErrorHandler.handleAuthError(e, context: 'Admin account creation');
      return {'success': false, 'message': e.message};
    } catch (e) {
      logger.error('Unexpected error during admin creation', e);
      ErrorHandler.handleError(e, context: 'Admin account creation');
      return {
        'success': false,
        'message': 'Admin account creation failed: ${e.toString()}',
      };
    }
  }

  Future<Map<String, dynamic>> loginAdmin(String email, String password) async {
    try {
      logger.info('Admin login attempt for: $email');

      if (email.trim().isEmpty || password.isEmpty) {
        return {'success': false, 'message': 'Email and password are required'};
      }

      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user != null) {
        // Load user profile to check if admin
        final userProfile = await _supabaseService.getUserById(
          response.user!.id,
        );

        if (userProfile != null && userProfile.role == RoleManager.roleAdmin) {
          final userController = Get.find<UserController>();
          userController.setUserProfile(userProfile);

          logger.info('Admin login successful: ${userProfile.name}');
          ErrorHandler.showSuccessSnackbar(
            'Welcome back, ${userProfile.name}!',
          );

          return {
            'success': true,
            'message': 'Admin login successful',
            'user': response.user,
          };
        } else {
          // User exists but is not admin
          await _client.auth.signOut();
          logger.warning('Non-admin user attempted admin login: $email');
          return {
            'success': false,
            'message': 'Access denied. Admin privileges required.',
          };
        }
      } else {
        return {'success': false, 'message': 'Login failed: No user returned'};
      }
    } on AuthException catch (e) {
      logger.error('Auth exception during admin login', e);
      ErrorHandler.handleAuthError(e, context: 'Admin login');
      return {'success': false, 'message': e.message};
    } catch (e) {
      logger.error('Unexpected error during admin login', e);
      ErrorHandler.handleError(e, context: 'Admin login');
      return {'success': false, 'message': 'Login failed: ${e.toString()}'};
    }
  }

  Future<void> logout() async {
    try {
      logger.info('Admin logout initiated');

      await _client.auth.signOut();

      final userController = Get.find<UserController>();
      userController.logout();

      logger.info('Admin logout completed successfully');
      ErrorHandler.showInfoSnackbar('Logged out successfully');
    } catch (e) {
      logger.error('Error during admin logout', e);
      ErrorHandler.handleError(e, context: 'Admin logout', showToUser: false);

      // Still clear local state even if logout fails
      final userController = Get.find<UserController>();
      userController.logout();
    }
  }

  /// Check if current session is valid admin session
  Future<bool> validateAdminSession() async {
    try {
      final session = _client.auth.currentSession;
      if (session == null) {
        logger.debug('No active session found');
        return false;
      }

      final userProfile = await _supabaseService.getUserById(session.user.id);
      if (userProfile == null || userProfile.role != RoleManager.roleAdmin) {
        logger.warning('Invalid admin session detected');
        await logout();
        return false;
      }

      logger.debug('Admin session validated successfully');
      return true;
    } catch (e) {
      logger.error('Error validating admin session', e);
      return false;
    }
  }

  /// Get current admin user info
  Future<Map<String, dynamic>?> getCurrentAdminInfo() async {
    try {
      final userController = Get.find<UserController>();
      if (!userController.isAdmin) {
        return null;
      }

      final profile = userController.userProfile.value;
      if (profile == null) {
        return null;
      }

      return {
        'id': profile.id,
        'simpleId': profile.simpleId,
        'name': profile.name,
        'email': profile.email,
        'role': profile.role,
        'createdAt': profile.createdAt?.toIso8601String(),
      };
    } catch (e) {
      logger.error('Error getting current admin info', e);
      return null;
    }
  }
}
