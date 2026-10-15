
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'features/saved/saved_words_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SavedWordsController.instance.loadSavedWords();

  runApp(const WordBloomApp());
}
  