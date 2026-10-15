
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class BloomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  const BloomNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.warmCream,
      indicatorColor: AppColors.blossomPink,
      elevation: 0,
      height: 75,
      labelBehavior:
          NavigationDestinationLabelBehavior.alwaysShow,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home_rounded),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book_rounded),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border_rounded),
          selectedIcon: Icon(Icons.bookmark_rounded),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: Icon(Icons.local_florist_outlined),
          selectedIcon: Icon(Icons.local_florist_rounded),
          label: 'Garden',
        ),
      ],
    );
  }
}
