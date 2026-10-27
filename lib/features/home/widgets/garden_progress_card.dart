import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../garden/learning_progress_controller.dart';

class GardenProgressCard extends StatefulWidget {
  const GardenProgressCard({super.key});

  @override
  State<GardenProgressCard> createState() => _GardenProgressCardState();
}

class _GardenProgressCardState extends State<GardenProgressCard> {
  final LearningProgressController _learning =
      LearningProgressController.instance;

  @override
  void initState() {
    super.initState();
    _learning.load();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _learning,
      builder: (context, child) {
        final learnedWords = _learning.learnedWordsCount;
        const goalWords = 20;

        final progress = (learnedWords / goalWords).clamp(0.0, 1.0);

        final IconData plantIcon;

        if (learnedWords >= 20) {
          plantIcon = Icons.local_florist;
        } else if (learnedWords >= 10) {
          plantIcon = Icons.park;
        } else if (learnedWords >= 5) {
          plantIcon = Icons.spa;
        } else {
          plantIcon = Icons.eco;
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.sageCard,
            borderRadius: BorderRadius.circular(26),
            border: Border.all(color: AppColors.sageBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'YOUR LEARNING JOURNEY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sagePrimary,
                  letterSpacing: 1,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  SizedBox(
                    width: 65,
                    child: Icon(
                      plantIcon,
                      size: 48,
                      color: AppColors.sagePrimary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$learnedWords ${learnedWords == 1 ? 'word' : 'words'} learned!',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.sageDark,
                          ),
                        ),

                        const SizedBox(height: 4),

                        const Text(
                          'Every new word is a little victory. 🌻',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.sageSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              const Divider(color: AppColors.sageBorder, height: 1),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'NEXT GARDEN MILESTONE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: AppColors.sagePrimary,
                    ),
                  ),
                  Text(
                    '$learnedWords / $goalWords',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageDark,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.sageBorder,
                  color: AppColors.sagePrimary,
                ),
              ),

              const SizedBox(height: 10),

              Center(
                child: Text(
                  learnedWords >= goalWords
                      ? 'Your garden is blooming!'
                      : '${goalWords - learnedWords} more words until your next bloom',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.sageSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
