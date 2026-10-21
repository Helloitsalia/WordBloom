import 'package:flutter/material.dart';

import '../../data/models/vocabulary_word.dart';
import '../../features/saved/saved_words_controller.dart';

class ExpandableWordCard extends StatefulWidget {
  final VocabularyWord word;

  const ExpandableWordCard({super.key, required this.word});

  @override
  State<ExpandableWordCard> createState() => _ExpandableWordCardState();
}

class _ExpandableWordCardState extends State<ExpandableWordCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final word = widget.word;
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(word.word, style: theme.textTheme.titleLarge),
                  ),
                  Chip(
                    label: Text(word.cefrLevel),
                    visualDensity: VisualDensity.compact,
                  ),
                  const SizedBox(width: 8),
                  ListenableBuilder(
                    listenable: SavedWordsController.instance,
                    builder: (context, _) {
                      final controller = SavedWordsController.instance;

                      final isSaved = controller.isSaved(word.id);

                      return IconButton(
                        tooltip: isSaved ? 'Remove saved word' : 'Save word',
                        icon: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border,
                          color: isSaved
                              ? const Color(0xFFA33E73)
                              : Colors.grey,
                        ),
                        onPressed: () {
                          controller.toggleSaved(word.id);
                        },
                      );
                    },
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: const Color(0xFFA33E73),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _isExpanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Divider(),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFEFF4),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'DEFINITION',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFA33E73),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(word.definition),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE9F4E9),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'EXAMPLE SENTENCE',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4B805F),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                word.example,
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (word.categories.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: word.categories.map((category) {
                              return Chip(label: Text(category));
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
