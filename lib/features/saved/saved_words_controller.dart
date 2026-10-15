
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedWordsController extends ChangeNotifier {
  SavedWordsController._();

  static final SavedWordsController instance =
      SavedWordsController._();

  static const String _storageKey = 'wordbloom_saved_word_ids';

  final Set<String> _savedIds = {};

  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  bool isSaved(String wordId) {
    return _savedIds.contains(wordId);
  }

  int get savedCount => _savedIds.length;

  Set<String> get savedIds => Set.unmodifiable(_savedIds);

  Future<void> loadSavedWords() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();
    final storedIds = prefs.getStringList(_storageKey) ?? [];

    _savedIds
      ..clear()
      ..addAll(storedIds);

    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggleSaved(String wordId) async {
    if (!_isLoaded) {
      await loadSavedWords();
    }

    final wasSaved = _savedIds.contains(wordId);

    if (wasSaved) {
      _savedIds.remove(wordId);
    } else {
      _savedIds.add(wordId);
    }

    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setStringList(
        _storageKey,
        _savedIds.toList(),
      );
    } catch (error) {
      if (wasSaved) {
        _savedIds.add(wordId);
      } else {
        _savedIds.remove(wordId);
      }

      notifyListeners();
      debugPrint('Could not save bookmarks: $error');
    }
  }
}
