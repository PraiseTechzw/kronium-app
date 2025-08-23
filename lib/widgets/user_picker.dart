import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kronium/core/app_theme.dart';
import 'package:kronium/core/user_controller.dart';
import 'package:kronium/models/user_model.dart';

class UserPicker extends StatelessWidget {
  const UserPicker({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Get.find<UserController>();

    return Obx(() {
      final availableUsers = userController.availableUsers;
      final selectedUser = userController.selectedUser.value;
      final selectedIndex = userController.selectedUserIndex.value;

      if (availableUsers.isEmpty) {
        return const SizedBox.shrink();
      }

      return Container(
        margin: const EdgeInsets.only(bottom: 12), // Reduced margin
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Select User Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (availableUsers.length > 1)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${selectedIndex + 1}/${availableUsers.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (availableUsers.length == 1)
              _buildSingleUserDisplay(selectedUser!)
            else
              _buildUserSelector(userController, availableUsers, selectedIndex),
          ],
        ),
      );
    });
  }

  Widget _buildSingleUserDisplay(User user) {
    return Row(
      children: [
        Container(
          width: 40, // Reduced size
          height: 40, // Reduced size
          decoration: BoxDecoration(
            color: AppTheme.secondaryColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20), // Reduced radius
            border: Border.all(
              color: AppTheme.secondaryColor.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.person,
            color: Colors.white,
            size: 20, // Reduced icon size
          ),
        ),
        const SizedBox(width: 12), // Reduced spacing
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                user.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16, // Reduced font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                user.email,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 12, // Reduced font size
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserSelector(
    UserController userController,
    List<User> users,
    int selectedIndex,
  ) {
    return Column(
      children: [
        // User cards
        SizedBox(
          height: 100, // Reduced height
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelected = index == selectedIndex;

              return GestureDetector(
                onTap: () => userController.selectUser(index),
                child: Container(
                  width: 180, // Reduced width
                  margin: EdgeInsets.only(
                    right: index < users.length - 1 ? 10 : 0, // Reduced margin
                  ),
                  padding: const EdgeInsets.all(12), // Reduced padding
                  decoration: BoxDecoration(
                    color:
                        isSelected
                            ? AppTheme.secondaryColor.withValues(alpha: 0.4)
                            : Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14), // Reduced radius
                    border: Border.all(
                      color:
                          isSelected
                              ? AppTheme.secondaryColor.withValues(alpha: 0.7)
                              : Colors.white.withValues(alpha: 0.2),
                      width: isSelected ? 2 : 1,
                    ),
                    boxShadow:
                        isSelected
                            ? [
                              BoxShadow(
                                color: AppTheme.secondaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 8, // Reduced blur
                                offset: const Offset(0, 3), // Reduced offset
                              ),
                            ]
                            : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 32, // Reduced size
                            height: 32, // Reduced size
                            decoration: BoxDecoration(
                              color:
                                  isSelected
                                      ? AppTheme.secondaryColor.withValues(
                                        alpha: 0.5,
                                      )
                                      : Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(
                                16,
                              ), // Reduced radius
                            ),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 16, // Reduced icon size
                            ),
                          ),
                          const SizedBox(width: 8), // Reduced spacing
                          Expanded(
                            child: Text(
                              user.name,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14, // Reduced font size
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: AppTheme.secondaryColor,
                              size: 16, // Reduced icon size
                            ),
                        ],
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      Text(
                        user.email,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 11, // Reduced font size
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3), // Reduced spacing
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6, // Reduced padding
                          vertical: 3, // Reduced padding
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(
                            6,
                          ), // Reduced radius
                        ),
                        child: Text(
                          'ID: ${user.id ?? 'N/A'}',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 9, // Reduced font size
                            fontFamily: 'monospace',
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8), // Reduced spacing
        // Navigation arrows
        if (users.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed:
                    selectedIndex > 0
                        ? () => userController.selectUser(selectedIndex - 1)
                        : null,
                icon: Icon(
                  Icons.arrow_back_ios,
                  color:
                      selectedIndex > 0
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                  size: 18, // Reduced icon size
                ),
              ),
              const SizedBox(width: 16), // Reduced spacing
              IconButton(
                onPressed:
                    selectedIndex < users.length - 1
                        ? () => userController.selectUser(selectedIndex + 1)
                        : null,
                icon: Icon(
                  Icons.arrow_forward_ios,
                  color:
                      selectedIndex < users.length - 1
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.3),
                  size: 18, // Reduced icon size
                ),
              ),
            ],
          ),
      ],
    );
  }
}
