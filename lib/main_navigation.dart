
import 'package:flutter/material.dart';

import 'features/home/home_screen.dart';
import 'features/discover/discover_screen.dart';
import 'features/saved/saved_screen.dart';
import 'features/garden/garden_screen.dart';

import 'shared/widgets/bloom_navigation_bar.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() =>
      _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    HomeScreen(),
    DiscoverScreen(),
    SavedScreen(),
    GardenScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BloomNavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onTabSelected,
      ),
    );
  }
}
