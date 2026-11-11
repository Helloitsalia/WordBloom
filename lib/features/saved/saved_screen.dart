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
      body: SafeArea(
        child: ListenableBuilder(
          listenable: SavedWordsController.instance,
          builder: (context, _) {
            return FutureBuilder<List<VocabularyWord>>(
              future: _wordsFuture,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Could not load saved words.'),
                  );
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
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Saved Words',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF304F40),
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Your saved words, anytime you need them.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF526B5D),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Image.asset(
                            'assets/images/learning/closed_book.png',
                            width: 68,
                            height: 68,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                    ),

                    // Compact collection summary
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 13,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8F1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFB9D4C1)),
                        ),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/learning/bookmark_leaf.png',
                              width: 26,
                              height: 34,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'My Collection',
                                style: TextStyle(
                                  color: Color(0xFF304F40),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF9E1E9),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${controller.savedCount} words saved',
                                style: const TextStyle(
                                  color: Color(0xFF944A70),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search saved words...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF526B5D),
                          ),
                          filled: true,
                          fillColor: const Color(0xFFE3E9E1),
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

                    // Existing saved word cards
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
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                              ),
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
      ),
    );
  }
}
