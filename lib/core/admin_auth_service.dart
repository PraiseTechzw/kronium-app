import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService extends GetxController {
  static AdminAuthService get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isAdminLoggedIn = false.obs;
  final Rx<User?> adminUser = Rx<User?>(null);
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    _setupAuthStateListener();
    _restoreAdminSession();
  }

  Future<void> _restoreAdminSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final adminEmail = prefs.getString('admin_email');
      
      if (adminEmail != null && adminEmail.isNotEmpty) {
        print('Found saved admin session: $adminEmail');
        
        // Check if there's a current Firebase user
        final currentUser = _auth.currentUser;
        if (currentUser != null && currentUser.email == adminEmail) {
          // User is already signed in with the admin email
          await _checkAdminStatus(currentUser);
        } else {
          // No Firebase user but we have admin email saved
          // This happens during hot reload - restore admin status from saved data
          print('Admin email found but no Firebase user - restoring admin status from saved session');
          
          // Set admin status to true based on saved session
          isAdminLoggedIn.value = true;
          adminUser.value = null; // No Firebase user but we're admin
          
          print('Admin session restored from SharedPreferences: $adminEmail');
        }
      }
    } catch (e) {
      print('Error restoring admin session: $e');
    }
  }

  void _setupAuthStateListener() {
    // Add a small delay to ensure Firebase is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      _auth.authStateChanges().listen((User? user) async {
        print('Admin auth state changed: ${user?.email ?? "null"}');
        if (user != null) {
          // Check if user is admin
          await _checkAdminStatus(user);
        } else {
          // User is signed out - check if we should clear admin session
          // Add a small delay to avoid race conditions with rapid auth changes
          await Future.delayed(const Duration(milliseconds: 100));
          final currentAuthUser = _auth.currentUser;
          
          if (currentAuthUser == null && isAdminLoggedIn.value) {
            // Check if we have a saved admin session
            final prefs = await SharedPreferences.getInstance();
            final adminEmail = prefs.getString('admin_email');
            
            if (adminEmail == null || adminEmail.isEmpty) {
              // No saved admin session, clear admin status
              print('Clearing admin session due to auth state change - no saved session');
              await _clearAdminSession();
            } else {
              // We have a saved admin session, keep admin status during hot reload
              print('Keeping admin session during hot reload - saved session exists: $adminEmail');
            }
          }
        }
        isInitialized.value = true;
      });

      // Also check current state immediately in case user is already signed in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _checkAdminStatus(currentUser);
      } else {
        // No Firebase user - check if we have saved admin session
        final prefs = await SharedPreferences.getInstance();
        final adminEmail = prefs.getString('admin_email');
        
        if (adminEmail != null && adminEmail.isNotEmpty && !isAdminLoggedIn.value) {
          // Restore admin session if not already restored
          print('Immediate check: Restoring admin session from SharedPreferences: $adminEmail');
          isAdminLoggedIn.value = true;
          adminUser.value = null;
        }
        
        isInitialized.value = true;
      }
    });
  }

  Future<void> _checkAdminStatus(User user) async {
    try {
      // Check if user is admin in Firestore
      final adminDoc =
          await _firestore.collection('admins').doc(user.uid).get();

      if (adminDoc.exists) {
        adminUser.value = user;
        isAdminLoggedIn.value = true;

        // Save admin session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_email', user.email ?? '');

        print('Admin session restored: ${user.email}');
      } else {
        // User is not admin - clear admin session but don't sign out
        // This allows regular users to remain signed in
        await _clearAdminSession();
        print('User ${user.email} is not an admin - clearing admin session');
      }
    } catch (e) {
      print('Error checking admin status: $e');
      await _clearAdminSession();
    }
  }

  Future<void> _clearAdminSession() async {
    adminUser.value = null;
    isAdminLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_email');

    print('Admin session cleared');
  }

  Future<Map<String, dynamic>> loginAsAdmin(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      // Check if user is admin in Firestore
      final adminDoc = await _firestore
          .collection('admins')
          .doc(userCredential.user!.uid)
          .get();
      if (adminDoc.exists) {
        adminUser.value = userCredential.user;
        isAdminLoggedIn.value = true;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('admin_email', email);
        return {'success': true, 'message': 'Admin login successful'};
      } else {
        await _auth.signOut();
        return {'success': false, 'message': 'This account is not authorized as admin'};
      }
    } catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e.toString());
      return {'success': false, 'message': errorMessage};
    }
  }

  Future<void> logout() async {
    await _logout();
  }

  Future<void> _logout() async {
    await _auth.signOut();
    adminUser.value = null;
    isAdminLoggedIn.value = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_email');
  }

  bool get isAdmin => isAdminLoggedIn.value;
  User? get currentAdmin => adminUser.value;

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No admin account found with this email address';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address format';
    } else if (error.contains('user-disabled')) {
      return 'This admin account has been disabled. Please contact support';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    } else if (error.contains('network-request-failed')) {
      return 'Network error. Please check your internet connection';
    } else if (error.contains('invalid-credential')) {
      return 'Invalid email or password';
    } else if (error.contains('operation-not-allowed')) {
      return 'Email/password accounts are not enabled. Please contact support';
    } else {
      return 'An error occurred. Please try again';
    }
  }

  // Create admin account
  Future<UserCredential?> createAdminAccount(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } catch (e) {
      Get.snackbar(
        'Account Creation Failed',
        'Failed to create admin account: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }
}
