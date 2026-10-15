
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'widgets/daily_word_card.dart';
import 'widgets/garden_progress_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WordBloom 🌸'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Good morning! ☀️',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkPlum,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Ready to grow a little today?',
                style: TextStyle(
                  color: AppColors.secondaryText,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 16),
const DailyWordCard(),
const SizedBox(height: 12),
const GardenProgressCard(),
            ],
          ),
        ),
      ),
    );
  }
}
