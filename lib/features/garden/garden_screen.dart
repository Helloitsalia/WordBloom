import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'learning_progress_controller.dart';
import '../../data/models/vocabulary_word.dart';
import '../../data/services/vocabulary_repository.dart';
import '../../shared/widgets/expandable_word_card.dart';

class GardenScreen extends StatefulWidget {
  const GardenScreen({super.key});

  @override
  State<GardenScreen> createState() => _GardenScreenState();
}

class _GardenScreenState extends State<GardenScreen> {
  final LearningProgressController _learning =
      LearningProgressController.instance;

  bool _showRepeat = false;

  final VocabularyRepository _repository = VocabularyRepository();

  late final Future<List<VocabularyWord>> _wordsFuture;

  @override
  void initState() {
    super.initState();
    _learning.load();
    _wordsFuture = _repository.loadWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListenableBuilder(
        listenable: _learning,
        builder: (context, child) {
          final plantedCount = _learning.learnedWordsCount;
          final repeatCount = _learning.repeatWordsCount;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'My Garden 🌻',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Grow your vocabulary, one word at a time.',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.sageSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildCountCard(
                          assetPath: 'assets/images/garden/potted_seedling.png',
                          count: plantedCount,
                          label: 'Planted Words',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildCountCard(
                          assetPath: 'assets/images/garden/watering_can.png',
                          count: repeatCount,
                          label: 'Words to Repeat',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: AppColors.sageCard,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppColors.sageBorder),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildGardenTab(
                            label: 'Planted',
                            selected: !_showRepeat,
                            onTap: () => setState(() => _showRepeat = false),
                          ),
                        ),
                        Expanded(
                          child: _buildGardenTab(
                            label: 'Repeat',
                            selected: _showRepeat,
                            onTap: () => setState(() => _showRepeat = true),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    _showRepeat ? 'Words to Review' : 'My Planted Words',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.sageDark,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    _showRepeat
                        ? '$repeatCount words are waiting for another practice session.'
                        : '$plantedCount words are growing in your Garden.',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.sageSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  FutureBuilder<List<VocabularyWord>>(
                    future: _wordsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Could not load vocabulary.');
                      }

                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final words = snapshot.data!
                          .where(
                            (word) => _showRepeat
                                ? _learning.isInRepeat(word.id)
                                : _learning.isPlanted(word.id),
                          )
                          .toList();

                      words.sort(
                        (a, b) => a.word.toLowerCase().compareTo(
                          b.word.toLowerCase(),
                        ),
                      );

                      if (words.isEmpty) {
                        return Text(
                          _showRepeat
                              ? 'No words to review yet! 🌻'
                              : 'Your garden is waiting for its first word. 🌱',
                          style: const TextStyle(
                            color: AppColors.sageSecondary,
                            fontSize: 13,
                          ),
                        );
                      }

                      return Column(
                        children: [
                          for (final word in words)
                            ExpandableWordCard(
                              key: ValueKey(word.id),
                              word: word,
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGardenTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.sagePrimary : Colors.transparent,
      borderRadius: BorderRadius.circular(26),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 13),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.sageDark,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountCard({
    required String assetPath,
    required int count,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.sageCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageBorder),
      ),

      child: Row(
        children: [
          Image.asset(assetPath, width: 64, height: 76, fit: BoxFit.contain),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: AppColors.sageDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.sageSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
