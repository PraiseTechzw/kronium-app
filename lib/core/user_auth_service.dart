import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService extends GetxController {
  static UserAuthService get instance => Get.find();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isUserLoggedIn = false.obs;
  final Rx<firebase_auth.User?> currentUser = Rx<firebase_auth.User?>(null);
  final Rx<User?> userProfile = Rx<User?>(null);
  final RxBool isInitialized = false.obs;

  UserController get userController => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    _setupAuthStateListener();
  }

  void _setupAuthStateListener() {
    // Add a small delay to ensure Firebase is fully initialized
    Future.delayed(const Duration(milliseconds: 500), () {
      _auth.authStateChanges().listen((firebase_auth.User? user) async {
        print('Auth state changed: ${user?.email ?? "null"}');
        if (user != null) {
          // User is signed in
          await _loadUserProfile(user);
        } else {
          // User is signed out - only clear if we were previously logged in
          // Add a small delay to avoid race conditions with rapid auth changes
          await Future.delayed(const Duration(milliseconds: 100));
          final currentAuthUser = _auth.currentUser;
          if (currentAuthUser == null && isUserLoggedIn.value) {
            print('Clearing user session due to auth state change');
            await _clearUserSession();
          }
        }
        isInitialized.value = true;
      });

      // Also check current state immediately in case user is already signed in
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        _loadUserProfile(currentUser);
      } else {
        isInitialized.value = true;
      }
    });
  }

  Future<void> _loadUserProfile(firebase_auth.User user) async {
    try {
      // Check if user profile exists in Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

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
        print('User profile loaded: ${userProfile.value?.name}');
        print('UserController userName: ${userController.userName.value}');
        print(
          'UserController userProfile: ${userController.userProfile.value?.name}',
        );
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

  Future<bool> registerUser(
    String name,
    String email,
    String phone,
    String password,
  ) async {
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
      userController.setUserProfile(
        user.copyWith(id: userCredential.user!.uid),
      );

      print('Registration successful: ${user.name}');
      print('UserController userName: ${userController.userName.value}');
      print(
        'UserController userProfile: ${userController.userProfile.value?.name}',
      );

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
      final userDoc =
          await _firestore
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

        print('Login successful: ${User.fromFirestore(userDoc).name}');
        print('UserController userName: ${userController.userName.value}');
        print(
          'UserController userProfile: ${userController.userProfile.value?.name}',
        );

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
        await _firestore.collection('users').doc(user.uid).update({
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

  // New method to load available users for selection
  Future<void> loadAvailableUsers() async {
    try {
      // For demo purposes, we'll create some sample users
      // In a real app, you might fetch these from Firestore or another source
      final sampleUsers = [
        User(
          id: 'user_001',
          name: 'Praise Masunga',
          email: 'praise@example.com',
          phone: '+1234567890',
          address: '123 Main St, City',
          isActive: true,
        ),
        User(
          id: 'user_002',
          name: 'John Doe',
          email: 'john@example.com',
          phone: '+0987654321',
          address: '456 Oak Ave, Town',
          isActive: true,
        ),
        User(
          id: 'user_003',
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '+1122334455',
          address: '789 Pine Rd, Village',
          isActive: true,
        ),
      ];

      // Set available users in the controller
      userController.setAvailableUsers(sampleUsers);

      print('Loaded ${sampleUsers.length} available users');
    } catch (e) {
      print('Error loading available users: $e');
    }
  }

  // Method to load users from Firestore (alternative to sample data)
  Future<void> loadUsersFromFirestore() async {
    try {
      final querySnapshot = await _firestore.collection('users').get();
      final users =
          querySnapshot.docs
              .map((doc) => User.fromFirestore(doc))
              .where((user) => user.isActive)
              .toList();

      userController.setAvailableUsers(users);
      print('Loaded ${users.length} users from Firestore');
    } catch (e) {
      print('Error loading users from Firestore: $e');
      // Fallback to sample data
      await loadAvailableUsers();
    }
  }

  // Method to manually add a user for testing
  Future<void> addTestUser(User user) async {
    try {
      final currentUsers = userController.availableUsers.toList();
      currentUsers.add(user);
      userController.setAvailableUsers(currentUsers);
      print('Added test user: ${user.name}');
    } catch (e) {
      print('Error adding test user: $e');
    }
  }

  // Method to remove a user by ID
  Future<void> removeUser(String userId) async {
    try {
      final currentUsers = userController.availableUsers.toList();
      currentUsers.removeWhere((user) => user.id == userId);
      userController.setAvailableUsers(currentUsers);
      print('Removed user with ID: $userId');
    } catch (e) {
      print('Error removing user: $e');
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
