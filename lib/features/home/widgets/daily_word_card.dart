import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_word.dart';
import '../../saved/saved_words_controller.dart';

class DailyWordCard extends StatelessWidget {
  final VocabularyWord word;
  final VoidCallback onLearnPressed;

  const DailyWordCard({
    super.key,
    required this.word,
    required this.onLearnPressed,
  });

  @override
  Widget build(BuildContext context) {
    final savedController = SavedWordsController.instance;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.sageCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.sageBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.spa_outlined,
                color: AppColors.sagePrimary,
                size: 17,
              ),
              const SizedBox(width: 6),
              const Expanded(
                child: Text(
                  "TODAY'S WORD",
                  style: TextStyle(
                    color: AppColors.sagePrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: savedController,
                builder: (context, child) {
                  final isSaved = savedController.isSaved(word.id);

                  return IconButton(
                    tooltip: isSaved ? 'Remove saved word' : 'Save this word',
                    onPressed: () async {
                      await savedController.toggleSaved(word.id);
                    },
                    icon: Image.asset(
                      isSaved
                          ? 'assets/images/learning/bookmark_flower.png'
                          : 'assets/images/learning/bookmark_leaf.png',
                      width: 26,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 4),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: AppColors.sageDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${word.cefrLevel} • ${word.partOfSpeech}',
                      style: const TextStyle(
                        color: AppColors.sageSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Image.asset(
                'assets/images/decor/sunflower.png',
                width: 62,
                height: 62,
                fit: BoxFit.contain,
              ),
            ],
          ),

          const SizedBox(height: 8),

          Text(
            word.definition,
            style: const TextStyle(color: AppColors.sageDark, fontSize: 14),
          ),

          const SizedBox(height: 8),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.example,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.sageSecondary,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: onLearnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text('Practice vocabulary →'),
            ),
          ),
        ],
      ),
    );
  }
}
