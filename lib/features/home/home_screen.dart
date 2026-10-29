import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/vocabulary_word.dart';
import '../../data/services/vocabulary_repository.dart';
import '../../shared/widgets/leaf_balance_badge.dart';
import '../practice/word_practice_card.dart';
import 'widgets/daily_word_card.dart';
import 'widgets/garden_progress_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final Future<List<VocabularyWord>> _wordsFuture;

  bool _isPracticing = false;

  @override
  void initState() {
    super.initState();
    _wordsFuture = VocabularyRepository().loadWords();
  }

  VocabularyWord selectTodaysWord(List<VocabularyWord> words) {
    final today = DateTime.now();

    final dayNumber =
        DateTime(today.year, today.month, today.day).millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;

    return words[dayNumber % words.length];
  }

  void _startPractice() {
    setState(() {
      _isPracticing = true;
    });
  }

  void _finishPractice() {
    setState(() {
      _isPracticing = false;
    });
  }

  Widget _buildWelcomeHeader(bool compact) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7F0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, little gardener! 🌱',
                  style: TextStyle(
                    color: AppColors.sageDark,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Ready to grow a little today?',
                  style: TextStyle(
                    color: AppColors.sageSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8),
          LeafBalanceBadge(),
        ],
      ),
    );
  }

  Widget _buildWordSection() {
    return FutureBuilder<List<VocabularyWord>>(
      future: _wordsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Text("Could not load today's word.");
        }

        final words = snapshot.data ?? [];

        if (words.isEmpty) {
          return const Text('No vocabulary words available yet.');
        }

        final todaysWord = selectTodaysWord(words);

        if (_isPracticing) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WordPracticeCard(word: todaysWord, allWords: words),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: _finishPractice,
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.sagePrimary,
                ),
                label: const Text(
                  "Back to Today's Word",
                  style: TextStyle(color: AppColors.sagePrimary),
                ),
              ),
            ],
          );
        }

        return DailyWordCard(word: todaysWord, onLearnPressed: _startPractice);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 50,
        centerTitle: true,
        titleSpacing: 0,
        title: Image.asset(
          'assets/images/branding/wordbloom_logo.png',
          height: 44,
          fit: BoxFit.contain,
          semanticLabel: 'WordBloom',
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableHeight = constraints.maxHeight;

            final compact = availableHeight < 650;
            final veryCompact = availableHeight < 540;

            final spacing = veryCompact
                ? 6.0
                : compact
                ? 9.0
                : 12.0;

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, compact ? 8 : 12),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: availableHeight - (compact ? 8 : 12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeHeader(compact),

                    SizedBox(height: spacing),

                    _buildWordSection(),

                    SizedBox(height: spacing),

                    const GardenProgressCard(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
