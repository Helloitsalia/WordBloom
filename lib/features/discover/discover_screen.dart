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
      appBar: AppBar(
        toolbarHeight: 100,
        titleSpacing: 20,
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Discover',
                    style: Theme.of(context).textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Find new words to grow your vocabulary.',
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Image.asset(
              'assets/images/learning/open_book.png',
              width: 64,
              height: 64,
              fit: BoxFit.contain,
            ),
          ],
        ),
      ),
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
                    hintStyle: const TextStyle(color: Color(0xFF898E83)),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFA2AA9C),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFFFF5E6),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 18,
                      horizontal: 20,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8CEB9),
                        width: 1.2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFFD8CEB9),
                        width: 1.2,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: const BorderSide(
                        color: Color(0xFF416C55),
                        width: 1.6,
                      ),
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

                    final selectedColors = <String, Color>{
                      'All': const Color(0xFFD3EBDD),
                      'A1': const Color(0xFFB8CCB2),
                      'A2': const Color(0xFFE0E6BA),
                      'B1': const Color(0xFFF6E8D3),
                      'B2': const Color(0xFFF7BEC9),
                      'C1': const Color(0xFFF69EAF),
                      'C2': const Color(0xFFB7CCAF),
                    };

                    final borderColors = <String, Color>{
                      'All': const Color(0xFF416C55),
                      'A1': const Color(0xFF64836A),
                      'A2': const Color(0xFF838E4D),
                      'B1': const Color(0xFFAA865D),
                      'B2': const Color(0xFFB9657D),
                      'C1': const Color(0xFFAE4E69),
                      'C2': const Color(0xFF5E8062),
                    };

                    final unselectedColors = <String, Color>{
                      'All': const Color(0xFFF7F9F5),
                      'A1': const Color(0xFFE3EBDF),
                      'A2': const Color(0xFFF0F2DC),
                      'B1': const Color(0xFFFFF3E3),
                      'B2': const Color(0xFFFCE4E9),
                      'C1': const Color(0xFFFFD6DF),
                      'C2': const Color(0xFFDFEBDD),
                    };

                    final isSelected = _selectedLevel == level;

                    return ChoiceChip(
                      label: Text(level),
                      selected: isSelected,
                      selectedColor: selectedColors[level],
                      backgroundColor: unselectedColors[level],
                      side: BorderSide(
                        color: isSelected
                            ? borderColors[level]!
                            : const Color(0xFFCCD7CE),
                        width: isSelected ? 1.8 : 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      labelStyle: const TextStyle(
                        color: Color(0xFF30483D),
                        fontWeight: FontWeight.w500,
                      ),
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
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${words.length} words found',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Image.asset(
                        'assets/images/decor/sprout.png',
                        width: 38,
                        height: 38,
                        fit: BoxFit.contain,
                      ),
                    ],
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
