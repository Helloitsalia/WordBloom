
import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/vocabulary_word.dart';

class VocabularyRepository {
  static const List<String> _vocabularyFiles = [
    'assets/vocabulary/wordbloom_cefr_100.json',
  ];

  Future<List<VocabularyWord>> loadWords() async {
    final List<VocabularyWord> words = [];
    final Set<String> loadedIds = {};

    for (final filePath in _vocabularyFiles) {
      final jsonString = await rootBundle.loadString(filePath);
      final List<dynamic> jsonData = jsonDecode(jsonString);

      for (final item in jsonData) {
        final word = VocabularyWord.fromJson(
          item as Map<String, dynamic>,
        );

        if (!loadedIds.add(word.id)) {
          throw FormatException(
            'Duplicate vocabulary ID: ${word.id}',
          );
        }

        words.add(word);
      }
    }

    return words;
  }
}
