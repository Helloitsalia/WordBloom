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
    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
          final selected = states.contains(WidgetState.selected);

          return TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.sagePrimary : AppColors.sageSecondary,
          );
        }),
      ),
      child: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
        backgroundColor: AppColors.warmCream,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 72,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              size: 27,
              color: AppColors.sageSecondary,
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              size: 27,
              color: AppColors.sagePrimary,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.search_rounded,
              size: 27,
              color: AppColors.sageSecondary,
            ),
            selectedIcon: Icon(
              Icons.search_rounded,
              size: 29,
              color: AppColors.sagePrimary,
            ),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.bookmark_border_rounded,
              size: 27,
              color: AppColors.sageSecondary,
            ),
            selectedIcon: Icon(
              Icons.bookmark_rounded,
              size: 27,
              color: AppColors.sagePrimary,
            ),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.local_florist_outlined,
              size: 27,
              color: AppColors.sageSecondary,
            ),
            selectedIcon: Icon(
              Icons.local_florist_rounded,
              size: 27,
              color: AppColors.sagePrimary,
            ),
            label: 'Garden',
          ),
        ],
      ),
    );
  }
}
