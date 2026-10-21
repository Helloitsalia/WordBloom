import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LearningProgressController extends ChangeNotifier {
  LearningProgressController._();

  static final LearningProgressController instance =
      LearningProgressController._();

  static const String _correctWordsKey = 'wordbloom_correctly_practiced_words';

  final Set<String> _correctWords = {};

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  int get correctlyPracticedCount => _correctWords.length;

  bool hasPracticedCorrectly(String wordId) {
    return _correctWords.contains(wordId);
  }

  Future<void> load() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    _correctWords
      ..clear()
      ..addAll(prefs.getStringList(_correctWordsKey) ?? []);

    _isLoaded = true;
    notifyListeners();
  }

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
        throw StateError('Could not save learning progress.');
      }

      return true;
    } catch (error) {
      _correctWords.remove(wordId);
      notifyListeners();

      debugPrint('Could not save learning progress: $error');
      return false;
    }
  }
}
