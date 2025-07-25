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
  
  @override
  void onInit() {
    super.onInit();
    _checkAdminSession();
  }
  
  Future<void> _checkAdminSession() async {
    final prefs = await SharedPreferences.getInstance();
    final adminEmail = prefs.getString('admin_email');
    
    if (adminEmail != null) {
      final user = _auth.currentUser;
      if (user != null && user.email == adminEmail) {
        // Verify if user is still admin in Firestore
        final adminDoc = await _firestore
            .collection('admins')
            .doc(user.uid)
            .get();
            
        if (adminDoc.exists) {
          adminUser.value = user;
          isAdminLoggedIn.value = true;
        } else {
          await _logout();
        }
      }
    }
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
  Future<UserCredential?> createAdminAccount(String email, String password) async {
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