import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';

// User roles: 'admin', 'customer', 'guest'
class UserController extends GetxController {
  RxString role = 'guest'.obs;
  RxString userId = ''.obs;
  RxString userSimpleId = ''.obs; // 4-character simple ID
  RxString userName = ''.obs;
  // Add more user info as needed
  Rx<User?> userProfile = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    print('UserController initialized');
  }

  void setRole(String newRole) {
    print('UserController: Setting role to $newRole');
    role.value = newRole;
  }

  void setUser(String id, String name, String newRole, {String? simpleId}) {
    print(
      'UserController: Setting user - ID: $id, SimpleID: $simpleId, Name: $name, Role: $newRole',
    );
    userId.value = id;
    userSimpleId.value = simpleId ?? '';
    userName.value = name;
    role.value = newRole;
  }

  void logout() {
    print('UserController: Logging out user');
    userId.value = '';
    userSimpleId.value = '';
    userName.value = '';
    role.value = 'guest';
    userProfile.value = null;
  }

  // Optionally, add a method to update userProfile
  void setUserProfile(User? profile) {
    print('UserController: Setting user profile - ${profile?.name ?? "null"}');
    userProfile.value = profile;
    if (profile != null) {
      userId.value = profile.id ?? '';
      userSimpleId.value = profile.simpleId ?? '';
      userName.value = profile.name;
      print(
        'UserController: Updated userId to ${userId.value}, simpleId to ${userSimpleId.value} and userName to ${userName.value}',
      );
    }
  }

  // Get display ID (simple ID if available, otherwise Firebase ID)
  String get displayId =>
      userSimpleId.value.isNotEmpty ? userSimpleId.value : userId.value;

  // Method to check if user is properly loaded
  bool get isUserLoaded => userId.value.isNotEmpty && userName.value.isNotEmpty;

  // Method to get current user info for debugging
  void printCurrentState() {
    print('UserController Current State:');
    print('  - userId: ${userId.value}');
    print('  - userName: ${userName.value}');
    print('  - role: ${role.value}');
    print('  - userProfile: ${userProfile.value?.name ?? "null"}');
  }
}
