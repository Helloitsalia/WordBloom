import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeafPointsController extends ChangeNotifier {
  LeafPointsController._();

  static final LeafPointsController instance = LeafPointsController._();

  static const String _balanceKey = 'wordbloom_leaf_balance';
  static const String _scoredKey = 'wordbloom_scored_questions';

  int _balance = 0;
  bool _isLoaded = false;
  final Set<String> _scoredQuestions = {};

  int get balance => _balance;
  bool get isLoaded => _isLoaded;

  Future<void> load() async {
    if (_isLoaded) return;

    final prefs = await SharedPreferences.getInstance();

    _balance = prefs.getInt(_balanceKey) ?? 0;

    _scoredQuestions
      ..clear()
      ..addAll(prefs.getStringList(_scoredKey) ?? []);

    _isLoaded = true;
    notifyListeners();
  }

  String _questionKey(String wordId) {
    final today = DateTime.now();

    final date =
        '${today.year}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';

    return '$date:$wordId';
  }

  bool hasScoredToday(String wordId) {
    return _scoredQuestions.contains(_questionKey(wordId));
  }

  bool hasUnscoredWordsToday(Iterable<String> wordIds) {
    return wordIds.any((id) => !hasScoredToday(id));
  }

  Future<bool> recordAnswer({
    required String wordId,
    required bool isCorrect,
  }) async {
    await load();

    final key = _questionKey(wordId);

    if (_scoredQuestions.contains(key)) {
      return false;
    }

    final previousBalance = _balance;

    _balance = isCorrect
        ? _balance + 1
        : (_balance - 1).clamp(0, 2147483647).toInt();

    _scoredQuestions.add(key);
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();

      final balanceSaved = await prefs.setInt(_balanceKey, _balance);

      final questionsSaved = await prefs.setStringList(
        _scoredKey,
        _scoredQuestions.toList(),
      );

      if (!balanceSaved || !questionsSaved) {
        throw StateError('Could not persist leaf points.');
      }

      return true;
    } catch (error) {
      _balance = previousBalance;
      _scoredQuestions.remove(key);
      notifyListeners();

      debugPrint('Could not save leaf points: $error');
      return false;
    }
  }
}
