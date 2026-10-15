
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class GardenProgressCard extends StatelessWidget {
  final int learnedWords;
  final int goalWords;
  final int streakDays;

  const GardenProgressCard({
    super.key,
    this.learnedWords = 12,
    this.goalWords = 20,
    this.streakDays = 3,
  });

  @override
  Widget build(BuildContext context) {
    final progress = goalWords > 0
        ? (learnedWords / goalWords).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.mintGreen.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🌱 MY LITTLE GARDEN',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF427455),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              '🌸',
              style: TextStyle(fontSize: 65),
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              '$learnedWords / $goalWords words',
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF365E45),
              ),
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: const Color(0xFFBED9C5),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF6CB386),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              '$streakDays-day streak 🔥',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF427455),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
