import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:kronium/core/app_theme.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool isDarkMode;

  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      backgroundColor: isDarkMode ? Colors.grey[850] : Colors.white,
      selectedItemColor: AppTheme.primaryColor,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Iconsax.home_2),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Iconsax.box),
          label: 'Services',
        ),
      ],
    );
  }
} 