import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/core/simple_id_generator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserAuthService extends GetxController {
  static UserAuthService get instance => Get.find();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isUserLoggedIn = false.obs;
  final Rx<firebase_auth.User?> currentUser = Rx<firebase_auth.User?>(null);
  final Rx<User?> userProfile = Rx<User?>(null);
  final RxBool isInitialized = false.obs;
  final RxBool isLoading = false.obs;
  bool _isRestoringSession =
      false; // Flag to prevent interference during restoration

  UserController get userController => Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    print('UserAuthService: Initializing...');
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      print('UserAuthService: Starting authentication initialization...');

      // Wait for Firebase to be fully ready
      await Future.delayed(const Duration(milliseconds: 1000));

      // Check if user is already signed in
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        print(
          'UserAuthService: Found existing Firebase user: ${firebaseUser.email}',
        );
        await _loadUserProfile(firebaseUser);
      } else {
        print(
          'UserAuthService: No Firebase user found, trying to restore from preferences...',
        );
        // Try to restore from preferences even if no Firebase user
        await _restoreSessionFromPreferences();
      }

      // Set up auth state listener
      _setupAuthStateListener();

      isInitialized.value = true;
      print('UserAuthService: Initialization complete');
    } catch (e) {
      print('UserAuthService: Error during initialization: $e');
      isInitialized.value = true;
    }
  }

  void _setupAuthStateListener() {
    print('UserAuthService: Setting up auth state listener...');

    _auth.authStateChanges().listen((firebase_auth.User? user) async {
      // Skip if we're in the middle of restoring a session
      if (_isRestoringSession) {
        print(
          'UserAuthService: Skipping auth state change during session restoration',
        );
        return;
      }

      print('UserAuthService: Auth state changed: ${user?.email ?? "null"}');

      if (user != null) {
        // User signed in
        print('UserAuthService: User signed in, loading profile...');
        await _loadUserProfile(user);
      } else {
        // User signed out - but be more careful about clearing
        print(
          'UserAuthService: Auth state shows no user, checking carefully...',
        );

        // Wait longer to see if this is just a temporary Firebase issue
        await Future.delayed(const Duration(milliseconds: 3000));

        // Check multiple times with longer delays
        bool shouldClear = true;
        for (int i = 0; i < 5; i++) {
          final currentFirebaseUser = _auth.currentUser;
          if (currentFirebaseUser != null) {
            print(
              'UserAuthService: Firebase user found on check $i, not clearing',
            );
            shouldClear = false;
            break;
          }
          await Future.delayed(const Duration(milliseconds: 1000));
        }

        // Only clear if we're absolutely sure and we have a session to clear
        // AND we haven't just restored a session from preferences
        if (shouldClear && isUserLoggedIn.value && userProfile.value != null) {
          // Check if we have a valid session from preferences before clearing
          final prefs = await SharedPreferences.getInstance();
          final savedEmail = prefs.getString('user_email');
          final savedUserId = prefs.getString('user_id');
          final savedUserName = prefs.getString('user_name');

          if (savedEmail != null &&
              savedUserId != null &&
              savedUserName != null) {
            print(
              'UserAuthService: Found saved session in preferences, not clearing current session',
            );
            // Try to restore the session instead of clearing it
            await _tryRestoreSession(
              savedEmail,
              savedUserId,
              savedUserName,
              'customer',
            );
            return;
          } else {
            print(
              'UserAuthService: No saved preferences found, clearing session',
            );
            await _clearUserSession();
          }
        } else if (shouldClear) {
          print('UserAuthService: No active session to clear');
        }
      }
    });
  }

  Future<void> _loadUserProfile(firebase_auth.User user) async {
    try {
      print('UserAuthService: Loading profile for: ${user.email}');

      // Get user document from Firestore
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        var userModel = User.fromFirestore(userDoc);

        // Generate simple ID if user doesn't have one
        if (userModel.simpleId == null || userModel.simpleId!.isEmpty) {
          print('UserAuthService: User missing simple ID, generating one...');
          final simpleId = SimpleIdGenerator.generateSimpleId();
          userModel = userModel.copyWith(simpleId: simpleId);

          // Update the user document in Firestore with the new simple ID
          await _firestore.collection('users').doc(user.uid).update({
            'simpleId': simpleId,
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print('UserAuthService: Generated simple ID: $simpleId');
        }

        print(
          'UserAuthService: Profile loaded from Firestore: ${userModel.name} (ID: ${userModel.simpleId})',
        );

        // Update service state
        currentUser.value = user;
        userProfile.value = userModel;
        isUserLoggedIn.value = true;

        // Update UserController with all necessary data
        final role = userData['role'] ?? 'customer';
        userController.role.value = role;
        userController.setUserProfile(userModel);

        // Ensure UserController has the correct user data
        if (userController.userName.value.isEmpty ||
            userController.userId.value.isEmpty) {
          print('UserAuthService: Forcing UserController synchronization...');
          userController.setUserProfile(userModel);
        }

        // Save to preferences
        await _saveSessionToPreferences(user, userModel);

        print('UserAuthService: Session fully restored for: ${userModel.name}');
        print(
          'UserAuthService: UserController updated - Name: ${userController.userName.value}, ID: ${userController.userId.value}',
        );
        print('UserAuthService: isUserLoggedIn: ${isUserLoggedIn.value}');
      } else {
        print('UserAuthService: User profile not found in Firestore');
        await _auth.signOut();
        await _clearUserSession();
      }
    } catch (e) {
      print('UserAuthService: Error loading profile: $e');
      await _auth.signOut();
      await _clearUserSession();
    }
  }

  Future<void> _saveSessionToPreferences(
    firebase_auth.User user,
    User profile,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', user.email ?? '');
      await prefs.setString('user_id', user.uid);
      await prefs.setString('user_name', profile.name);
      // Note: role is stored separately in UserController, not in User model
      print('UserAuthService: Session saved to preferences');
    } catch (e) {
      print('UserAuthService: Error saving to preferences: $e');
    }
  }

  Future<void> _restoreSessionFromPreferences() async {
    try {
      print('UserAuthService: Attempting to restore from preferences...');

      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('user_email');
      final savedUserId = prefs.getString('user_id');
      final savedUserName = prefs.getString('user_name');
      final savedRole = prefs.getString('user_role') ?? 'customer';

      if (savedEmail != null && savedUserId != null && savedUserName != null) {
        print('UserAuthService: Found saved session: $savedEmail');

        // Check if Firebase has this user
        final firebaseUser = _auth.currentUser;

        if (firebaseUser != null && firebaseUser.email == savedEmail) {
          print(
            'UserAuthService: Firebase user matches saved session, loading profile...',
          );
          await _loadUserProfile(firebaseUser);
        } else if (firebaseUser != null && firebaseUser.email != savedEmail) {
          print(
            'UserAuthService: Firebase user exists but email mismatch, updating preferences...',
          );
          // Update preferences with current Firebase user
          await prefs.setString('user_email', firebaseUser.email ?? '');
          await prefs.setString('user_id', firebaseUser.uid);
          await _loadUserProfile(firebaseUser);
        } else {
          print(
            'UserAuthService: No Firebase user found, but we have saved preferences',
          );
          print(
            'UserAuthService: This might indicate a session restoration issue',
          );

          // Try to restore the session manually from saved data
          await _tryRestoreSession(
            savedEmail,
            savedUserId,
            savedUserName,
            savedRole,
          );
        }
      } else {
        print('UserAuthService: No saved session found in preferences');
      }
    } catch (e) {
      print('UserAuthService: Error restoring from preferences: $e');
    }
  }

  Future<void> _tryRestoreSession(
    String email,
    String userId,
    String userName,
    String role,
  ) async {
    try {
      print('UserAuthService: Attempting to restore session manually...');
      _isRestoringSession = true; // Set flag to prevent interference

      // Create a temporary user profile from saved data
      final tempUser = User(
        id: userId,
        name: userName,
        email: email,
        phone: '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Set the profile in our service
      userProfile.value = tempUser;
      isUserLoggedIn.value = true;
      currentUser.value = null; // No Firebase user yet

      // Update UserController
      userController.role.value = role;
      userController.setUserProfile(tempUser);

      print('UserAuthService: Session restored manually from preferences');
      print(
        'UserAuthService: User: ${tempUser.name}, Email: ${tempUser.email}',
      );
      print('UserAuthService: isUserLoggedIn: ${isUserLoggedIn.value}');
      print(
        'UserAuthService: UserController - Name: ${userController.userName.value}, ID: ${userController.userId.value}',
      );

      // Clear the flag after a delay to allow the session to stabilize
      Future.delayed(const Duration(milliseconds: 2000), () {
        _isRestoringSession = false;
        print('UserAuthService: Session restoration flag cleared');
      });
    } catch (e) {
      print('UserAuthService: Error in manual session restoration: $e');
      _isRestoringSession = false;
    }
  }

  Future<void> _clearPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
      print('UserAuthService: Old preferences cleared');
    } catch (e) {
      print('UserAuthService: Error clearing preferences: $e');
    }
  }

  Future<void> _clearUserSession() async {
    print('UserAuthService: Clearing user session...');

    currentUser.value = null;
    userProfile.value = null;
    isUserLoggedIn.value = false;
    userController.logout();

    // Clear preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('user_email');
      await prefs.remove('user_id');
      await prefs.remove('user_name');
      await prefs.remove('user_role');
    } catch (e) {
      print('UserAuthService: Error clearing preferences: $e');
    }

    print('UserAuthService: User session cleared');
  }

  // Public methods
  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      if (isLoading.value) {
        print('UserAuthService: Login already in progress, skipping...');
        return {'success': false, 'message': 'Login already in progress'};
      }

      isLoading.value = true;
      print('UserAuthService: Attempting login for: $email');

      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        print('UserAuthService: Login successful, loading profile...');
        await _loadUserProfile(user);
        return {'success': true, 'message': 'Login successful'};
      }

      return {'success': false, 'message': 'Login failed - no user returned'};
    } catch (e) {
      print('UserAuthService: Login error: $e');
      String errorMessage = _getFirebaseErrorMessage(e.toString());
      return {'success': false, 'message': errorMessage};
    } finally {
      isLoading.value = false;
    }
  }

  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String phone,
    String password,
  ) async {
    try {
      isLoading.value = true;
      print('UserAuthService: Attempting registration for: $email');

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = userCredential.user;

      if (user != null) {
        // Create user profile with simple ID
        final userModel = User.create(
          name: name,
          email: email,
          phone: phone,
        ).copyWith(id: user.uid);

        // Save to Firestore with role
        final userData = userModel.toFirestore();
        userData['role'] = 'customer'; // Add role to Firestore data

        await _firestore.collection('users').doc(user.uid).set(userData);

        print('UserAuthService: Registration successful, setting profile...');
        await _loadUserProfile(user);
        return {'success': true, 'message': 'Account created successfully'};
      }

      return {
        'success': false,
        'message': 'Registration failed - no user returned',
      };
    } catch (e) {
      print('UserAuthService: Registration error: $e');
      String errorMessage = _getFirebaseErrorMessage(e.toString());
      return {'success': false, 'message': errorMessage};
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    print('UserAuthService: Logging out user...');
    await _auth.signOut();
    await _clearUserSession();
  }

  // Profile update methods
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final user = currentUser.value;
      if (user != null) {
        print('UserAuthService: Updating user profile...');

        // Update in Firestore
        await _firestore.collection('users').doc(user.uid).update({
          ...data,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Update local profile
        if (userProfile.value != null) {
          final updatedProfile = userProfile.value!.copyWith(
            name: data['name'] ?? userProfile.value!.name,
            phone: data['phone'] ?? userProfile.value!.phone,
            address: data['address'] ?? userProfile.value!.address,
            updatedAt: DateTime.now(),
          );
          userProfile.value = updatedProfile;

          // Update UserController
          userController.setUserProfile(updatedProfile);
        }

        // Update preferences
        if (data['name'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_name', data['name']);
        }

        print('UserAuthService: Profile updated successfully');
      }
    } catch (e) {
      print('UserAuthService: Error updating profile: $e');
      rethrow;
    }
  }

  Future<bool> changePassword(String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        print('UserAuthService: Changing password...');
        await user.updatePassword(newPassword);
        print('UserAuthService: Password changed successfully');
        return true;
      }
      return false;
    } catch (e) {
      print('UserAuthService: Error changing password: $e');
      return false;
    }
  }

  // Getters
  bool get isLoggedIn => isUserLoggedIn.value;
  User? get currentUserProfile => userProfile.value;
  firebase_auth.FirebaseAuth get auth => _auth;

  // Force refresh methods
  Future<void> forceRefreshSession() async {
    print('UserAuthService: Force refreshing session...');
    final firebaseUser = _auth.currentUser;
    if (firebaseUser != null) {
      await _loadUserProfile(firebaseUser);
    } else {
      print('UserAuthService: No Firebase user found, cannot refresh session');
    }
  }

  Future<void> forceRestoreFromPreferences() async {
    print('UserAuthService: Force restoring from preferences...');
    await _restoreSessionFromPreferences();
  }

  // Active session validation
  Future<void> validateAndRefreshSession() async {
    print('UserAuthService: Validating current session...');

    // Check if we have a valid session
    if (isUserLoggedIn.value && userProfile.value != null) {
      print('UserAuthService: Session appears valid, checking Firebase...');

      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        print('UserAuthService: Firebase user found, refreshing profile...');
        await _loadUserProfile(firebaseUser);
      } else {
        print(
          'UserAuthService: No Firebase user but session exists, trying to restore...',
        );
        await _restoreSessionFromPreferences();
      }
    } else {
      print('UserAuthService: No valid session found, checking Firebase...');
      final firebaseUser = _auth.currentUser;
      if (firebaseUser != null) {
        print('UserAuthService: Firebase user found, loading profile...');
        await _loadUserProfile(firebaseUser);
      } else {
        print('UserAuthService: No Firebase user and no session');
      }
    }
  }

  bool get isSessionValid {
    final hasUser = currentUser.value != null;
    final hasProfile = userProfile.value != null;
    final isLoggedIn = isUserLoggedIn.value;

    print(
      'UserAuthService: Session validation - Firebase: $hasUser, Profile: $hasProfile, LoggedIn: $isLoggedIn',
    );
    return hasUser && hasProfile && isLoggedIn;
  }

  // Helper method to convert Firebase error codes to user-friendly messages
  String _getFirebaseErrorMessage(String error) {
    if (error.contains('user-not-found')) {
      return 'No account found with this email address';
    } else if (error.contains('wrong-password')) {
      return 'Incorrect password. Please try again';
    } else if (error.contains('invalid-email')) {
      return 'Invalid email address format';
    } else if (error.contains('user-disabled')) {
      return 'This account has been disabled. Please contact support';
    } else if (error.contains('too-many-requests')) {
      return 'Too many failed attempts. Please try again later';
    } else if (error.contains('email-already-in-use')) {
      return 'An account with this email already exists';
    } else if (error.contains('weak-password')) {
      return 'Password is too weak. Please choose a stronger password';
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
}
