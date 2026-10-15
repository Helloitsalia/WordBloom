
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class DailyWordCard extends StatelessWidget {
  const DailyWordCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blossomPink.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '✿ TODAY\'S WORD',
                style: TextStyle(
                  color: AppColors.berry,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  letterSpacing: 1.2,
                ),
              ),
              Icon(
                Icons.auto_awesome,
                color: AppColors.berry,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Flourish',
            style: TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: AppColors.darkPlum,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '/ˈflʌr.ɪʃ/  •  B2  •  verb',
            style: TextStyle(
              color: AppColors.secondaryText,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'To grow, develop, or become successful.',
            style: TextStyle(
              color: AppColors.darkPlum,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Text(
              'Small habits help you flourish.',
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.berry,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 11,
                ),
              ),
              child: const Text('Learn this word →'),
            ),
          ),
        ],
      ),
    );
  }
}
