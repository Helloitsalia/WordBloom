import 'package:flutter/material.dart';

import '../../shared/widgets/expandable_word_card.dart';
import '../../data/models/vocabulary_word.dart';
import '../../data/services/vocabulary_repository.dart';
import 'saved_words_controller.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late final Future<List<VocabularyWord>> _wordsFuture;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _wordsFuture = VocabularyRepository().loadWords();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Words 💗'), centerTitle: true),
      body: ListenableBuilder(
        listenable: SavedWordsController.instance,
        builder: (context, _) {
          return FutureBuilder<List<VocabularyWord>>(
            future: _wordsFuture,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Center(child: Text('Could not load saved words.'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final controller = SavedWordsController.instance;

              final savedWords = snapshot.data!
                  .where((word) => controller.isSaved(word.id))
                  .where(
                    (word) => word.word.toLowerCase().contains(
                      _searchQuery.toLowerCase().trim(),
                    ),
                  )
                  .toList();

              savedWords.sort((a, b) => a.word.compareTo(b.word));

              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9E1E9),
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'YOUR LITTLE WORD COLLECTION',
                            style: TextStyle(
                              color: Color(0xFFA33E73),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${controller.savedCount} words saved',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Every new word is a little step forward. 🌱',
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search saved words...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => _searchQuery = value);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: savedWords.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Text(
                                controller.savedCount == 0
                                    ? 'No saved words yet 🌷\n'
                                          'Explore Discover and bookmark a word!'
                                    : 'No matching saved words.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: savedWords.length,
                            itemBuilder: (context, index) {
                              final word = savedWords[index];

                              return ExpandableWordCard(
                                key: ValueKey(word.id),
                                word: word,
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
