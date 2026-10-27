class VocabularyWord {
  final String id;
  final String word;
  final String partOfSpeech;
  final String cefrLevel;
  final String definition;
  final String example;
  final List<String> categories;
  final String reviewStatus;

  const VocabularyWord({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.cefrLevel,
    required this.definition,
    required this.example,
    required this.categories,
    required this.reviewStatus,
  });

  factory VocabularyWord.fromJson(Map<String, dynamic> json) {
    return VocabularyWord(
      id: json['id'] as String,
      word: json['word'] as String,
      partOfSpeech: json['partOfSpeech'] as String,
      cefrLevel: json['cefrLevel'] as String,
      definition: json['definition'] as String,
      example: json['example'] as String,
      categories: List<String>.from(json['categories'] ?? []),
      reviewStatus: json['reviewStatus'] as String? ?? 'needs_review',
    );
  }
}
