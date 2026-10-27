import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DailyPracticeController extends ChangeNotifier {
  DailyPracticeController._();

  static final DailyPracticeController instance = DailyPracticeController._();

  static const int freeDailyQuestions = 5;
  static const int questionsPerReward = 5;

  static const String _dateKey = 'wordbloom_practice_date';
  static const String _usedKey = 'wordbloom_practice_used';
  static const String _bonusKey = 'wordbloom_practice_bonus';

  bool _isLoaded = false;
  String _date = '';
  int _usedQuestions = 0;
  int _bonusQuestions = 0;

  bool get isLoaded => _isLoaded;
  int get usedQuestions => _usedQuestions;
  int get bonusQuestions => _bonusQuestions;

  int get totalAllowance => freeDailyQuestions + _bonusQuestions;

  int get remainingQuestions =>
      (totalAllowance - _usedQuestions).clamp(0, 1000000);

  bool get canPractice => remainingQuestions > 0;

  bool get dailyFreeCompleted => _usedQuestions >= freeDailyQuestions;

  String _todayKey() {
    final now = DateTime.now();

    return '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    if (_isLoaded && _date == today) return;

    final savedDate = prefs.getString(_dateKey);

    if (savedDate == today) {
      _usedQuestions = prefs.getInt(_usedKey) ?? 0;
      _bonusQuestions = prefs.getInt(_bonusKey) ?? 0;
    } else {
      _usedQuestions = 0;
      _bonusQuestions = 0;

      await prefs.setString(_dateKey, today);
      await prefs.setInt(_usedKey, 0);
      await prefs.setInt(_bonusKey, 0);
    }

    _date = today;
    _isLoaded = true;
    notifyListeners();
  }

  Future<bool> recordCompletedQuestion() async {
    await load();

    if (!canPractice) return false;

    final prefs = await SharedPreferences.getInstance();
    final previousUsed = _usedQuestions;

    _usedQuestions++;
    notifyListeners();

    try {
      final saved = await prefs.setInt(_usedKey, _usedQuestions);

      if (!saved) {
        throw StateError('Could not save practice progress.');
      }

      return true;
    } catch (error) {
      _usedQuestions = previousUsed;
      notifyListeners();

      debugPrint('Could not save practice progress: $error');
      return false;
    }
  }
  // Developer testing only.
// Resets today's used questions without changing bonus credits,
// leaf points, or learning progress.
Future<bool> debugResetDailyQuestions() async {
  if (!kDebugMode) return false;

  await load();

  final prefs = await SharedPreferences.getInstance();
  final previousUsed = _usedQuestions;

  try {
    final saved = await prefs.setInt(_usedKey, 0);

    if (!saved) {
      throw StateError('Could not reset daily questions.');
    }

    _usedQuestions = 0;
    notifyListeners();

    return true;
  } catch (error) {
    _usedQuestions = previousUsed;
    debugPrint('Developer reset failed: $error');
    return false;
  }
}

  // Reserved for future rewarded-ad integration.
  // Never call this method just because an ad was opened.
  Future<bool> grantRewardedQuestions() async {
    await load();

    final prefs = await SharedPreferences.getInstance();
    final previousBonus = _bonusQuestions;

    _bonusQuestions += questionsPerReward;
    notifyListeners();

    try {
      final saved = await prefs.setInt(_bonusKey, _bonusQuestions);

      if (!saved) {
        throw StateError('Could not save bonus questions.');
      }

      return true;
    } catch (error) {
      _bonusQuestions = previousBonus;
      notifyListeners();

      debugPrint('Could not save rewarded questions: $error');
      return false;
    }
  }
}
