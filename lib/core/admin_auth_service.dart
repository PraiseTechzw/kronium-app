import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/supabase_service.dart';

/// Admin authentication service using Supabase Auth
class AdminAuthService {
  static final AdminAuthService instance = AdminAuthService._();
  AdminAuthService._();

  SupabaseClient get _client => Supabase.instance.client;
  SupabaseService get _supabaseService => SupabaseService.instance;

  bool get isAdminLoggedIn {
    final userController = Get.find<UserController>();
    return userController.role.value == 'admin';
  }

  Future<Map<String, dynamic>> createAdminAccount(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create auth user
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: {
          'name': name,
          'role': 'admin',
        },
      );

      if (response.user != null) {
        // Create admin user profile in users table
        try {
          final userController = Get.find<UserController>();
          await _supabaseService.addAdmin(response.user!.id, {
            'name': name,
            'email': email.trim(),
            'role': 'admin',
            'created_at': DateTime.now().toIso8601String(),
          });

          // Load admin profile
          final adminUser = await _supabaseService.getUserById(response.user!.id);
          if (adminUser != null) {
            userController.setUserProfile(adminUser);
            userController.setRole('admin');
          }

          return {
            'success': true,
            'message': 'Admin account created successfully',
            'user': response.user,
          };
        } catch (e) {
          print('Error creating admin profile: $e');
          return {
            'success': false,
            'message': 'Admin account created but profile creation failed: ${e.toString()}',
          };
        }
      } else {
        return {
          'success': false,
          'message': 'Admin account creation failed: No user returned',
        };
      }
    } on AuthException catch (e) {
      return {
        'success': false,
        'message': e.message,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Admin account creation failed: ${e.toString()}',
      };
    }
  }

  Future<void> logout() async {
    try {
      await _client.auth.signOut();
      
      final userController = Get.find<UserController>();
      userController.logout();
    } catch (e) {
      print('Error during admin logout: $e');
      // Still clear local state
      final userController = Get.find<UserController>();
      userController.logout();
    }
  }
}
