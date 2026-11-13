import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../models/vocabulary_word.dart';

class VocabularyRepository {
  static const String _databaseAsset = 'assets/database/content.db';

  static const String _legacyJsonAsset =
      'assets/vocabulary/wordbloom_cefr_100.json';

  static const String _databaseFilename = 'wordbloom_content_v1.db';

  Future<List<VocabularyWord>> loadWords() async {
    final databasePath = p.join(await getDatabasesPath(), _databaseFilename);

    final databaseFile = File(databasePath);

    if (!await databaseFile.exists()) {
      final data = await rootBundle.load(_databaseAsset);

      final bytes = Uint8List.sublistView(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );

      await databaseFile.parent.create(recursive: true);
      await databaseFile.writeAsBytes(bytes, flush: true);
    }

    final database = await openDatabase(databasePath, readOnly: true);

    final words = <VocabularyWord>[];
    final loadedIds = <String>{};

    try {
      final rows = await database.rawQuery('''
        SELECT
          w.*,
          GROUP_CONCAT(wc.collection_id) AS collections
        FROM words w
        LEFT JOIN word_collections wc
          ON wc.word_id = w.id
        GROUP BY w.id
        ORDER BY w.id
      ''');

      for (final row in rows) {
        final word = VocabularyWord(
          id: row['id'] as String,
          word: row['word'] as String,
          partOfSpeech: row['part_of_speech'] as String,
          cefrLevel: row['cefr_level'] as String,
          definition: row['definition'] as String,
          example: row['example'] as String,
          categories: (row['categories'] as String)
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(),
          collections: ((row['collections'] as String?) ?? '')
              .split(',')
              .map((value) => value.trim())
              .where((value) => value.isNotEmpty)
              .toList(),
          reviewStatus: row['review_status'] as String,
        );

        if (!loadedIds.add(word.id)) {
          throw FormatException('Duplicate vocabulary ID: ${word.id}');
        }

        words.add(word);
      }
    } finally {
      await database.close();
    }

    final jsonString = await rootBundle.loadString(_legacyJsonAsset);

    final legacyData = jsonDecode(jsonString) as List<dynamic>;

    for (final item in legacyData) {
      final word = VocabularyWord.fromJson(item as Map<String, dynamic>);

      if (loadedIds.add(word.id)) {
        words.add(word);
      }
    }

    return words;
  }
}
