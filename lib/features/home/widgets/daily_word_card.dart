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
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sageCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.sageBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.spa_outlined,
                    color: AppColors.sagePrimary,
                    size: 18,
                  ),
                  SizedBox(width: 6),
                  Text(
                    "TODAY'S WORD",
                    style: TextStyle(
                      color: AppColors.sagePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),

              // Bookmark button
              ListenableBuilder(
                listenable: savedController,
                builder: (context, child) {
                  final isSaved = savedController.isSaved(word.id);

                  return IconButton(
                    tooltip: isSaved ? 'Remove saved word' : 'Save this word',
                    onPressed: () async {
                      await savedController.toggleSaved(word.id);
                    },
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: AppColors.sagePrimary,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Today's vocabulary word
          Text(
            word.word,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.bold,
              color: AppColors.sageDark,
            ),
          ),

          const SizedBox(height: 6),

          // CEFR level and part of speech
          Text(
            '${word.cefrLevel} • ${word.partOfSpeech}',
            style: const TextStyle(
              color: AppColors.sageSecondary,
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 10),

          // Definition
          Text(
            word.definition,
            style: const TextStyle(color: AppColors.sageDark, fontSize: 15),
          ),

          const SizedBox(height: 10),

          // Example sentence
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              word.example,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.sageSecondary,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Learning button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onLearnPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.sagePrimary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 11),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
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
