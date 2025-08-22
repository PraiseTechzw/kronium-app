import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kronium/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService extends GetxController {
  static UserAuthService get instance => Get.find();
  
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isUserLoggedIn = false.obs;
  final Rx<firebase_auth.User?> currentUser = Rx<firebase_auth.User?>(null);
  final Rx<User?> userProfile = Rx<User?>(null);
  final RxBool isInitialized = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    _setupAuthStateListener();
  }
  
  void _setupAuthStateListener() {
    _auth.authStateChanges().listen((firebase_auth.User? user) async {
      if (user != null) {
        // User is signed in
        await _loadUserProfile(user);
      } else {
        // User is signed out
        await _clearUserSession();
      }
      isInitialized.value = true;
    });
  }
  
  Future<void> _loadUserProfile(firebase_auth.User user) async {
    try {
      // Check if user profile exists in Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .get();
          
      if (userDoc.exists) {
        currentUser.value = user;
        userProfile.value = User.fromFirestore(userDoc);
        isUserLoggedIn.value = true;
        
        // Set role in userController from Firestore, default to 'customer'
        final role = userDoc.data()?['role'] ?? 'customer';
        userController.role.value = role;
        userController.setUserProfile(User.fromFirestore(userDoc));
        
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', user.email ?? '');
        
        print('User session restored: ${user.email}');
      } else {
        // User profile doesn't exist, sign out
        await _auth.signOut();
        await _clearUserSession();
      }
    } catch (e) {
      print('Error loading user profile: $e');
      await _auth.signOut();
      await _clearUserSession();
    }
  }
  
  Future<void> _clearUserSession() async {
    currentUser.value = null;
    userProfile.value = null;
    isUserLoggedIn.value = false;
    userController.logout();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
    
    print('User session cleared');
  }
  
  Future<void> _checkUserSession() async {
    // This method is now deprecated in favor of auth state listener
    // Keeping for backward compatibility
    final prefs = await SharedPreferences.getInstance();
    final userEmail = prefs.getString('user_email');
    
    if (userEmail != null) {
      final user = _auth.currentUser;
      if (user != null && user.email == userEmail) {
        await _loadUserProfile(user);
      }
    }
    isInitialized.value = true;
  }
  
  Future<bool> registerUser(String name, String email, String phone, String password) async {
    try {
      // Create Firebase Auth user
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user profile in Firestore with role 'customer'
      final user = User(
        name: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        // Add role field if your User model supports it
        // role: 'customer',
      );
      final userData = user.toFirestore();
      userData['role'] = 'customer';
      
      await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(userData);
      
      // Set current user
      currentUser.value = userCredential.user;
      userProfile.value = user.copyWith(id: userCredential.user!.uid);
      isUserLoggedIn.value = true;
      // Set role in userController
      userController.role.value = 'customer';
      userController.setUserProfile(user.copyWith(id: userCredential.user!.uid));
      
      // Save user session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', email);
      
      Get.snackbar(
        'Success',
        'Account created successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      return true;
    } catch (e) {
      String errorMessage = 'Registration failed';
      if (e.toString().contains('email-already-in-use')) {
        errorMessage = 'Email is already registered';
      } else if (e.toString().contains('weak-password')) {
        errorMessage = 'Password is too weak';
      }
      
      Get.snackbar(
        'Registration Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  Future<bool> loginUser(String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get user profile from Firestore
      final userDoc = await _firestore
          .collection('users')
          .doc(userCredential.user!.uid)
          .get();
          
      if (userDoc.exists) {
        currentUser.value = userCredential.user;
        userProfile.value = User.fromFirestore(userDoc);
        isUserLoggedIn.value = true;
        // Set role in userController from Firestore, default to 'customer'
        final role = userDoc.data()?['role'] ?? 'customer';
        userController.role.value = role;
        userController.setUserProfile(User.fromFirestore(userDoc));
        
        // Save user session
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_email', email);
        
        Get.snackbar(
          'Success',
          'Welcome back!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        return true;
      } else {
        await _auth.signOut();
        Get.snackbar(
          'Error',
          'User profile not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Login failed';
      if (e.toString().contains('user-not-found')) {
        errorMessage = 'No account found with this email';
      } else if (e.toString().contains('wrong-password')) {
        errorMessage = 'Incorrect password';
      }
      
      Get.snackbar(
        'Login Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  Future<void> logout() async {
    await _logout();
  }
  
  Future<void> _logout() async {
    await _auth.signOut();
    currentUser.value = null;
    userProfile.value = null;
    isUserLoggedIn.value = false;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_email');
  }
  
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser.value;
      if (user != null) {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        // Update local profile
        if (userProfile.value != null) {
          userProfile.value = userProfile.value!.copyWith(
            name: data['name'] ?? userProfile.value!.name,
            phone: data['phone'] ?? userProfile.value!.phone,
            address: data['address'] ?? userProfile.value!.address,
            updatedAt: DateTime.now(),
          );
        }
        
        Get.snackbar(
          'Success',
          'Profile updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update profile',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  /// Changes the current user's password. Returns true if successful.
  Future<bool> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        Get.snackbar(
          'Success',
          'Password updated successfully!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        return true;
      } else {
        Get.snackbar(
          'Error',
          'No user is currently logged in.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      String errorMessage = 'Failed to update password.';
      if (e.toString().contains('requires-recent-login')) {
        errorMessage = 'Please re-login and try again.';
      }
      Get.snackbar(
        'Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return false;
    }
  }
  
  bool get isLoggedIn => isUserLoggedIn.value;
  User? get currentUserProfile => userProfile.value;
  firebase_auth.FirebaseAuth get auth => _auth;
}

// User roles: 'admin', 'customer', 'guest'
class UserController extends GetxController {
  RxString role = 'guest'.obs;
  RxString userId = ''.obs;
  RxString userName = ''.obs;
  // Add more user info as needed
  Rx<User?> userProfile = Rx<User?>(null);

  void setRole(String newRole) {
    role.value = newRole;
  }

  void setUser(String id, String name, String newRole) {
    userId.value = id;
    userName.value = name;
    role.value = newRole;
  }

  void logout() {
    userId.value = '';
    userName.value = '';
    role.value = 'guest';
    userProfile.value = null;
  }
  // Optionally, add a method to update userProfile
  void setUserProfile(User? profile) {
    userProfile.value = profile;
  }
}

final userController = Get.put(UserController(), permanent: true); 