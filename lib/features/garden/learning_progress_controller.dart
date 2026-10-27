import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningProgressController extends ChangeNotifier {
  LearningProgressController._();

  static final LearningProgressController instance =
      LearningProgressController._();

  static const String _correctWordsKey = 'wordbloom_correctly_practiced_words';

  static const String _plantedWordsKey = 'wordbloom_planted_words';

  final Set<String> _correctWords = {};
  final Set<String> _plantedWords = {};

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  // Quiz history
  int get correctlyPracticedCount => _correctWords.length;

  bool hasPracticedCorrectly(String wordId) {
    return _correctWords.contains(wordId);
  }

  // Manual learning progress
  int get learnedWordsCount => _plantedWords.length;

  bool isPlanted(String wordId) {
    return _plantedWords.contains(wordId);
  }

  Future<void> load() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    _correctWords
      ..clear()
      ..addAll(prefs.getStringList(_correctWordsKey) ?? []);

    _plantedWords
      ..clear()
      ..addAll(prefs.getStringList(_plantedWordsKey) ?? []);

    _isLoaded = true;
    notifyListeners();
  }

  // Record a correct quiz answer without planting the word.
  Future<bool> recordCorrectWord(String wordId) async {
    await load();

    if (_correctWords.contains(wordId)) {
      return true;
    }

    _correctWords.add(wordId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setStringList(
        _correctWordsKey,
        _correctWords.toList(),
      );

      if (!saved) {
        throw StateError('Could not save correct word history.');
      }

      return true;
    } catch (error) {
      _correctWords.remove(wordId);
      notifyListeners();

      debugPrint('Could not save correct word history: $error');
      return false;
    }
  }

  // Manually plant a word in the Garden.
  Future<bool> plantWord(String wordId) async {
    await load();

    if (_plantedWords.contains(wordId)) {
      return true;
    }

    _plantedWords.add(wordId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final saved = await prefs.setStringList(
        _plantedWordsKey,
        _plantedWords.toList(),
      );

      if (!saved) {
        throw StateError('Could not save planted word.');
      }

      return true;
    } catch (error) {
      _plantedWords.remove(wordId);
      notifyListeners();

      debugPrint('Could not plant word: $error');
      return false;
    }
  }
}
