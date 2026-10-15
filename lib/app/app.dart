
import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../main_navigation.dart';

class WordBloomApp extends StatelessWidget {
  const WordBloomApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WordBloom',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const MainNavigation(),
    );
  }
}
