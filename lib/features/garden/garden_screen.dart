import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class GardenScreen extends StatelessWidget {
  const GardenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Little Garden 🌱')),
      body: const Center(
        child: Text(
          'Every word helps your garden grow! 🌸',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: AppColors.darkPlum),
        ),
      ),
    );
  }
}
