import 'package:flutter/material.dart';

import '../../data/models/vocabulary_word.dart';
import '../../shared/widgets/expandable_word_card.dart';
import '../../data/services/vocabulary_repository.dart';


class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final VocabularyRepository _repository = VocabularyRepository();

  late Future<List<VocabularyWord>> _wordsFuture;

  String _searchQuery = '';
  String _selectedLevel = 'All';

  final List<String> _levels = ['All', 'A1', 'A2', 'B1', 'B2', 'C1', 'C2'];

  @override
  void initState() {
    super.initState();
    _wordsFuture = _repository.loadWords();
  }

  List<VocabularyWord> _filterWords(List<VocabularyWord> words) {
    final filtered = words.where((word) {
      final matchesLevel =
          _selectedLevel == 'All' || word.cefrLevel == _selectedLevel;

      final query = _searchQuery.toLowerCase().trim();

      final matchesSearch =
          word.word.toLowerCase().contains(query) ||
          word.definition.toLowerCase().contains(query);

      return matchesLevel && matchesSearch;
    }).toList();

    filtered.sort(
      (a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()),
    );

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Discover 🌷'), centerTitle: true),
      body: FutureBuilder<List<VocabularyWord>>(
        future: _wordsFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Could not load vocabulary:\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final words = _filterWords(snapshot.data!);

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search words...',
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

              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  scrollDirection: Axis.horizontal,
                  itemCount: _levels.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final level = _levels[index];

                    return ChoiceChip(
                      label: Text(level),
                      selected: _selectedLevel == level,
                      onSelected: (_) {
                        setState(() => _selectedLevel = level);
                      },
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${words.length} words found',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: words.length,
                  itemBuilder: (context, index) {
                    final word = words[index];

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
      ),
    );
  }
}
