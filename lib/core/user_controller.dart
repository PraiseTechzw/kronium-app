import 'package:get/get.dart';
import 'package:kronium/models/user_model.dart';

// User roles: 'admin', 'customer', 'guest'
class UserController extends GetxController {
  RxString role = 'guest'.obs;
  RxString userId = ''.obs;
  RxString userName = ''.obs;
  // Add more user info as needed
  Rx<User?> userProfile = Rx<User?>(null);

  // New fields for user selection
  RxList<User> availableUsers = <User>[].obs;
  RxInt selectedUserIndex = 0.obs;
  Rx<User?> selectedUser = Rx<User?>(null);

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
    selectedUser.value = null;
    selectedUserIndex.value = 0;
  }

  // Optionally, add a method to update userProfile
  void setUserProfile(User? profile) {
    userProfile.value = profile;
    if (profile != null) {
      userId.value = profile.id ?? '';
      userName.value = profile.name;
    }
  }

  // New methods for user selection
  void setAvailableUsers(List<User> users) {
    availableUsers.value = users;
    if (users.isNotEmpty) {
      selectedUserIndex.value = 0;
      selectedUser.value = users.first;
      _updateSelectedUser();
    }
  }

  void selectUser(int index) {
    if (index >= 0 && index < availableUsers.length) {
      selectedUserIndex.value = index;
      selectedUser.value = availableUsers[index];
      _updateSelectedUser();
    }
  }

  void selectUserById(String userId) {
    final index = availableUsers.indexWhere((user) => user.id == userId);
    if (index != -1) {
      selectUser(index);
    }
  }

  void _updateSelectedUser() {
    final user = selectedUser.value;
    if (user != null) {
      userId.value = user.id ?? '';
      userName.value = user.name;
      userProfile.value = user;
    }
  }

  // Get current selected user info
  User? get currentUser => selectedUser.value;
  String get currentUserId => selectedUser.value?.id ?? '';
  String get currentUserName => selectedUser.value?.name ?? '';
}
