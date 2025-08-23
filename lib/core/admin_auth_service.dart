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
          // User is signed out - only clear if we were previously logged in
          // Add a small delay to avoid race conditions with rapid auth changes
          await Future.delayed(const Duration(milliseconds: 100));
          final currentAuthUser = _auth.currentUser;
          if (currentAuthUser == null && isAdminLoggedIn.value) {
            print('Clearing admin session due to auth state change');
            await _clearAdminSession();
          }
        }
        isInitialized.value = true;
      });

      // Also check current state immediately in case user is already signed in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _checkAdminStatus(currentUser);
      } else {
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
        // User is not admin, sign out
        await _auth.signOut();
        await _clearAdminSession();
      }
    } catch (e) {
      print('Error checking admin status: $e');
      await _auth.signOut();
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

  // Future<bool> loginAsAdmin(String email, String password) async {
  //   try {
  //     final userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email,
  //       password: password,
  //     );
  //     // Check if user is admin in Firestore
  //     final adminDoc = await _firestore
  //         .collection('admins')
  //         .doc(userCredential.user!.uid)
  //         .get();
  //     if (adminDoc.exists) {
  //       adminUser.value = userCredential.user;
  //       isAdminLoggedIn.value = true;
  //       final prefs = await SharedPreferences.getInstance();
  //       await prefs.setString('admin_email', email);
  //       return true;
  //     } else {
  //       await _auth.signOut();
  //       Get.snackbar(
  //         'Access Denied',
  //         'This account is not authorized as admin',
  //         snackPosition: SnackPosition.BOTTOM,
  //       );
  //       return false;
  //     }
  //   } catch (e) {
  //     Get.snackbar(
  //       'Login Failed',
  //       'Invalid email or password',
  //       snackPosition: SnackPosition.BOTTOM,
  //     );
  //     return false;
  //   }
  // }

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
