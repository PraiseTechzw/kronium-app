import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';

// User roles: 'admin', 'customer', 'guest'
class UserController extends GetxController {
  RxString role = 'guest'.obs;
  RxString userId = ''.obs;
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

  void setUser(String id, String name, String newRole) {
    print(
      'UserController: Setting user - ID: $id, Name: $name, Role: $newRole',
    );
    userId.value = id;
    userName.value = name;
    role.value = newRole;
  }

  void logout() {
    print('UserController: Logging out user');
    userId.value = '';
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
      userName.value = profile.name;
      print(
        'UserController: Updated userId to ${userId.value} and userName to ${userName.value}',
      );
    }
  }

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
