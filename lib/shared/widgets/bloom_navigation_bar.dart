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

  Widget _navIcon(String assetPath, {bool selected = false}) {
    return Image.asset(
      assetPath,
      width: selected ? 30 : 27,
      height: selected ? 30 : 27,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );
  }

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: AppColors.warmCream,
      indicatorColor: AppColors.blossomPink,
      elevation: 0,
      height: 75,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      destinations: [
        NavigationDestination(
          icon: _navIcon('assets/images/nav/home.png'),
          selectedIcon: _navIcon('assets/images/nav/home.png', selected: true),
          label: 'Home',
        ),
        NavigationDestination(
          icon: _navIcon('assets/images/nav/search.png'),
          selectedIcon: _navIcon(
            'assets/images/nav/search.png',
            selected: true,
          ),
          label: 'Discover',
        ),
        NavigationDestination(
          icon: _navIcon('assets/images/nav/saved.png'),
          selectedIcon: _navIcon('assets/images/nav/saved.png', selected: true),
          label: 'Saved',
        ),
        NavigationDestination(
          icon: _navIcon('assets/images/nav/garden.png'),
          selectedIcon: _navIcon(
            'assets/images/nav/garden.png',
            selected: true,
          ),
          label: 'Garden',
        ),
      ],
    );
  }
}
