import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningProgressController extends ChangeNotifier {
  LearningProgressController._();

  static final LearningProgressController instance =
      LearningProgressController._();

  static const String _correctWordsKey = 'wordbloom_correctly_practiced_words';

  static const String _plantedWordsKey = 'wordbloom_planted_words';
  static const String _repeatWordsKey = 'wordbloom_repeat_words';

  final Set<String> _correctWords = {};
  final Set<String> _plantedWords = {};
  final Set<String> _repeatWords = {};

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

  // Words saved for future repetition.
  int get repeatWordsCount => _repeatWords.length;

  bool isInRepeat(String wordId) {
    return _repeatWords.contains(wordId);
  }

  Set<String> get repeatWordIds => Set.unmodifiable(_repeatWords);

  Future<void> load() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    _correctWords
      ..clear()
      ..addAll(prefs.getStringList(_correctWordsKey) ?? []);

    _plantedWords
      ..clear()
      ..addAll(prefs.getStringList(_plantedWordsKey) ?? []);

    _repeatWords
      ..clear()
      ..addAll(prefs.getStringList(_repeatWordsKey) ?? []);

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
      return removeFromRepeat(wordId);
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

      return await removeFromRepeat(wordId);
    } catch (error) {
      _plantedWords.remove(wordId);
      notifyListeners();

      debugPrint('Could not plant word: $error');
      return false;
    }
  }

  // Save a word for future repetition.
  Future<bool> addToRepeat(String wordId) async {
    await load();

    // Already planted words do not need regular repetition.
    if (_plantedWords.contains(wordId)) return false;

    if (_repeatWords.contains(wordId)) return true;

    _repeatWords.add(wordId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setStringList(
        _repeatWordsKey,
        _repeatWords.toList(),
      );

      if (!saved) {
        throw StateError('Could not save Repeat word.');
      }

      return true;
    } catch (error) {
      _repeatWords.remove(wordId);
      notifyListeners();

      debugPrint('Could not add word to Repeat: $error');
      return false;
    }
  }

  // Remove a word from Repeat.
  Future<bool> removeFromRepeat(String wordId) async {
    await load();

    if (!_repeatWords.contains(wordId)) return true;

    _repeatWords.remove(wordId);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setStringList(
        _repeatWordsKey,
        _repeatWords.toList(),
      );

      if (!saved) {
        throw StateError('Could not remove Repeat word.');
      }

      return true;
    } catch (error) {
      _repeatWords.add(wordId);
      notifyListeners();

      debugPrint('Could not remove word from Repeat: $error');
      return false;
    }
  }

  // Move a previously learned word back to Repeat after a wrong answer.
  Future<bool> movePlantedWordToRepeat(String wordId) async {
    await load();

    if (!_plantedWords.contains(wordId)) {
      return addToRepeat(wordId);
    }

    try {
      final prefs = await SharedPreferences.getInstance();

      // First, make sure the word is safely stored in Repeat.
      if (!_repeatWords.contains(wordId)) {
        final updatedRepeat = {..._repeatWords, wordId};

        final repeatSaved = await prefs.setStringList(
          _repeatWordsKey,
          updatedRepeat.toList(),
        );

        if (!repeatSaved) {
          throw StateError('Could not save word to Repeat.');
        }

        _repeatWords.add(wordId);
      }

      // Only remove the word from Garden after Repeat is saved.
      final updatedGarden = {..._plantedWords}..remove(wordId);

      final gardenSaved = await prefs.setStringList(
        _plantedWordsKey,
        updatedGarden.toList(),
      );

      if (!gardenSaved) {
        throw StateError('Could not remove word from Garden.');
      }

      _plantedWords.remove(wordId);
      notifyListeners();

      return true;
    } catch (error) {
      debugPrint('Could not move planted word to Repeat: $error');
      notifyListeners();
      return false;
    }
  }
}
