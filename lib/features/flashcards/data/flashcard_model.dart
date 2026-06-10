class FlashcardModel {
  const FlashcardModel({
    required this.wordId,
    required this.englishWord,
    required this.translations,
  });

  final int wordId;
  final String englishWord;
  final List<String> translations;

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    final rawTranslations = json['translations'] as List<dynamic>? ?? const [];

    return FlashcardModel(
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      englishWord: (json['englishWord'] as String?) ?? '',
      translations: rawTranslations.map((e) => e.toString()).toList(),
    );
  }
}
