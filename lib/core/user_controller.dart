import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';

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
    if (profile != null) {
      userId.value = profile.id ?? '';
      userName.value = profile.name;
    }
  }
}
