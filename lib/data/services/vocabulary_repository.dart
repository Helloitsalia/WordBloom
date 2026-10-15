
import 'dart:convert';
import 'package:flutter/services.dart';

import '../models/vocabulary_word.dart';

class VocabularyRepository {
  Future<List<VocabularyWord>> loadWords() async {
    final jsonString = await rootBundle.loadString(
      'assets/vocabulary/wordbloom_cefr_100.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    return jsonData.map((item) {
      return VocabularyWord.fromJson(
        item as Map<String, dynamic>,
      );
    }).toList();
  }
}
