import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/models/vocabulary_word.dart';
import '../garden/leaf_points_controller.dart';
import '../garden/learning_progress_controller.dart';
import 'daily_practice_controller.dart';

class WordPracticeCard extends StatefulWidget {
  final VocabularyWord word;
  final List<VocabularyWord> allWords;

  const WordPracticeCard({
    super.key,
    required this.word,
    required this.allWords,
  });

  @override
  State<WordPracticeCard> createState() => _WordPracticeCardState();
}

class _WordPracticeCardState extends State<WordPracticeCard> {
  static const int _sessionLimit = 5;

  final LeafPointsController _leaves = LeafPointsController.instance;
  final LearningProgressController _learning =
      LearningProgressController.instance;
  final DailyPracticeController _practice = DailyPracticeController.instance;
  final Random _random = Random();

  late VocabularyWord _currentWord;
  late List<String> _options;

  final Set<String> _sessionWords = {};

  String? _selectedAnswer;

  int _questionNumber = 1;
  int _correctAnswers = 0;
  int _incorrectAnswers = 0;
  int _netLeaves = 0;

  bool _hasChecked = false;
  bool _isSubmitting = false;
  bool _wasCorrect = false;
  bool _earnedPoint = false;
  bool _saveFailed = false;
  bool _sessionComplete = false;

  @override
  void initState() {
    super.initState();
    _currentWord = widget.word;
    _generateOptions();
    _initializeSession();
  }

  Future<void> _initializeSession() async {
    await Future.wait([_leaves.load(), _practice.load(), _learning.load()]);

    if (!mounted) return;

    setState(() {
      if (_practice.canPractice) {
        _startSession();
      }
    });
  }

  void _startSession() {
    _sessionWords.clear();
    _questionNumber = 1;
    _correctAnswers = 0;
    _incorrectAnswers = 0;
    _netLeaves = 0;
    _sessionComplete = false;

    _currentWord = _chooseWord(excludeIds: _sessionWords) ?? widget.word;

    _sessionWords.add(_currentWord.id);
    _resetQuestion();
  }

  VocabularyWord? _chooseWord({required Set<String> excludeIds}) {
    final available = widget.allWords
        .where((word) => !excludeIds.contains(word.id))
        .toList();

    if (available.isEmpty) return null;

    // Prioritize words not scored today.
    final unscored = available
        .where((word) => !_leaves.hasScoredToday(word.id))
        .toList();

    final candidates = unscored.isNotEmpty ? unscored : available;

    return candidates[_random.nextInt(candidates.length)];
  }

  void _generateOptions() {
    final correctDefinition = _currentWord.definition;

    final incorrectDefinitions = widget.allWords
        .where(
          (word) =>
              word.id != _currentWord.id &&
              word.definition != correctDefinition,
        )
        .map((word) => word.definition)
        .toSet()
        .toList();

    incorrectDefinitions.shuffle(_random);

    _options = [correctDefinition, ...incorrectDefinitions.take(2)];

    _options.shuffle(_random);
  }

  void _resetQuestion() {
    _selectedAnswer = null;
    _hasChecked = false;
    _isSubmitting = false;
    _wasCorrect = false;
    _earnedPoint = false;
    _saveFailed = false;
    _generateOptions();
  }

  Future<void> _checkAnswer() async {
    if (_selectedAnswer == null || _hasChecked || _isSubmitting) {
      return;
    }

    setState(() {
      _isSubmitting = true;
      _saveFailed = false;
    });

    // Refresh the daily allowance before submitting.
    await _practice.load();

    if (!_practice.canPractice) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    // Save the question usage first.
    final questionSaved = await _practice.recordCompletedQuestion();

    if (!questionSaved) {
      if (!mounted) return;

      setState(() {
        _isSubmitting = false;
        _saveFailed = true;
      });
      return;
    }

    final correct = _selectedAnswer == _currentWord.definition;
    final alreadyScored = _leaves.hasScoredToday(_currentWord.id);
    final balanceBefore = _leaves.balance;

    final recorded = await _leaves.recordAnswer(
      wordId: _currentWord.id,
      isCorrect: correct,
    );

    if (!mounted) return;

    final leafSaveFailed = !recorded && !alreadyScored;
    bool learningSaveFailed = false;

    if (correct) {
      final saved = await _learning.recordCorrectWord(_currentWord.id);
      learningSaveFailed = !saved;
    }

    if (!mounted) return;

    setState(() {
      _isSubmitting = false;
      _hasChecked = true;
      _wasCorrect = correct;
      _earnedPoint = recorded;
      _saveFailed = leafSaveFailed || learningSaveFailed;

      if (correct) {
        _correctAnswers++;
      } else {
        _incorrectAnswers++;
      }

      if (recorded) {
        _netLeaves += _leaves.balance - balanceBefore;
      }
    });
  }

  void _nextQuestion() {
    if (!_hasChecked) return;

    if (_questionNumber >= _sessionLimit ||
        _sessionWords.length >= widget.allWords.length ||
        !_practice.canPractice) {
      setState(() {
        _sessionComplete = true;
      });
      return;
    }

    final nextWord = _chooseWord(excludeIds: _sessionWords);

    if (nextWord == null) {
      setState(() {
        _sessionComplete = true;
      });
      return;
    }

    setState(() {
      _questionNumber++;
      _currentWord = nextWord;
      _sessionWords.add(nextWord.id);
      _resetQuestion();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.sageCard,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.sageBorder),
      ),

      child: !_practice.isLoaded
          ? const Center(child: CircularProgressIndicator())
          : !_practice.canPractice && !_hasChecked && !_sessionComplete
          ? _buildDailyLimit()
          : _sessionComplete
          ? _buildSummary()
          : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'WORD PRACTICE',
              style: TextStyle(
                color: AppColors.sagePrimary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.1,
              ),
            ),
            Text(
              '$_questionNumber / $_sessionLimit',
              style: const TextStyle(
                color: AppColors.sageSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _questionNumber / _sessionLimit,
            minHeight: 7,
            backgroundColor: AppColors.sageBorder,
            color: AppColors.sagePrimary,
          ),
        ),

        const SizedBox(height: 20),

        Text(
          'What does "${_currentWord.word}" mean?',
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
            color: AppColors.sageDark,
          ),
        ),

        const SizedBox(height: 16),

        ..._options.map((option) {
          final isSelected = _selectedAnswer == option;

          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: _hasChecked || _isSubmitting
                  ? null
                  : () {
                      setState(() {
                        _selectedAnswer = option;
                      });
                    },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.sageLight : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.sagePrimary
                        : AppColors.sageBorder,
                  ),
                ),
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.sageDark,
                  ),
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 8),

        if (!_hasChecked)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedAnswer == null || _isSubmitting
                  ? null
                  : _checkAnswer,
              child: Text(
                _isSubmitting ? 'Saving answer...' : 'Check my answer',
              ),
            ),
          ),

        if (_saveFailed)
          const Padding(
            padding: EdgeInsets.only(top: 12),
            child: Text(
              'Could not save your result. Please try again.',
              style: TextStyle(color: Colors.red),
            ),
          ),

        if (_hasChecked) ...[
          const SizedBox(height: 14),

          Text(
            _wasCorrect
                ? (_earnedPoint
                      ? 'Correct! +1 leaf!'
                      : 'Correct! Already scored today.')
                : (_earnedPoint
                      ? 'Incorrect! Leaf balance updated.'
                      : 'Incorrect! Already scored today.'),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _wasCorrect ? AppColors.sagePrimary : Colors.red.shade700,
            ),
          ),

          if (!_wasCorrect) ...[
            const SizedBox(height: 8),
            Text(
              'Correct answer: ${_currentWord.definition}',
              style: const TextStyle(
                color: AppColors.sageSecondary,
                fontSize: 13,
              ),
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _nextQuestion,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                _questionNumber >= _sessionLimit || !_practice.canPractice
                    ? 'See my results'
                    : 'Next question',
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDailyLimit() {
    return Column(
      children: [
        const Icon(Icons.spa, size: 54, color: AppColors.sagePrimary),
        const SizedBox(height: 14),
        const Text(
          'Daily practice complete!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
            color: AppColors.sageDark,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You have used your available questions today. '
          'Come back tomorrow for 5 new free questions!',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.sageSecondary, fontSize: 14),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.play_circle_outline),
            label: const Text('Watch an ad - Unlock 5 questions'),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Rewarded ads coming soon',
          style: TextStyle(color: AppColors.sageSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      children: [
        const Icon(Icons.spa, size: 54, color: AppColors.sagePrimary),

        const SizedBox(height: 12),

        const Text(
          'Practice complete!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.sageDark,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          '$_correctAnswers correct • $_incorrectAnswers incorrect',
          style: const TextStyle(color: AppColors.sageSecondary),
        ),

        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.sageLight,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'LEAVES THIS SESSION',
                style: TextStyle(
                  color: AppColors.sageSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${_netLeaves >= 0 ? '+' : ''}$_netLeaves',
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sagePrimary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _practice.canPractice
                ? () {
                    setState(() {
                      _startSession();
                    });
                  }
                : () {
                    setState(() {
                      _sessionComplete = false;
                      _hasChecked = false;
                    });
                  },
            icon: Icon(
              _practice.canPractice
                  ? Icons.arrow_forward
                  : Icons.check_circle_outline,
            ),
            label: Text(
              _practice.canPractice
                  ? 'Continue practicing'
                  : 'Daily practice completed',
            ),
          ),
        ),
      ],
    );
  }
}
