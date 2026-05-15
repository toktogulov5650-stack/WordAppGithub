import 'package:flutter/material.dart';

class UnknownWordModel {
  const UnknownWordModel({
    required this.wordId,
    required this.englishWord,
    required this.primaryTranslation,
  });

  final int wordId;
  final String englishWord;
  final String primaryTranslation;

  factory UnknownWordModel.fromJson(Map<String, dynamic> json) {
    return UnknownWordModel(
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      englishWord: (json['englishWord'] as String?) ?? '',
      primaryTranslation:
          (json['primaryTranslation'] as String?) ??
          (json['translations'] as String?) ??
          '',
    );
  }
}

class WordByCategoryModel {
  const WordByCategoryModel({
    required this.wordId,
    required this.englishWord,
    this.primaryTranslation,
  });

  final int wordId;
  final String englishWord;
  final String? primaryTranslation;

  factory WordByCategoryModel.fromJson(Map<String, dynamic> json) {
    final translations = json['translations'];

    final primaryTranslation =
        json['primaryTranslation'] as String? ??
        (translations is String
            ? translations
            : translations is Iterable
                ? translations.join(', ')
                : null);

    return WordByCategoryModel(
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      englishWord: (json['englishWord'] as String?) ?? '',
      primaryTranslation:
          primaryTranslation == null || primaryTranslation.trim().isEmpty
              ? null
              : primaryTranslation,
    );
  }
}

class ExampleModel {
  const ExampleModel({
    required this.order,
    required this.text,
    required this.translation,
  });

  final int order;
  final String text;
  final String translation;

  factory ExampleModel.fromJson(Map<String, dynamic> json) {
    return ExampleModel(
      order: (json['order'] as num?)?.toInt() ?? 0,
      text: (json['text'] as String?) ?? '',
      translation: (json['translation'] as String?) ?? '',
    );
  }
}

class WordExplanationModel {
  const WordExplanationModel({
    required this.wordId,
    required this.englishWord,
    this.whatIs,
    this.meaning,
    this.translations,
    this.usage,
    this.examples = const [],
    this.hint,
  });

  final int wordId;
  final String englishWord;

  final String? whatIs;
  final String? meaning;
  final String? translations;
  final String? usage;
  final String? hint;

  final List<ExampleModel> examples;

  factory WordExplanationModel.fromJson(Map<String, dynamic> json) {
    final rawExamples = json['examples'];

    return WordExplanationModel(
      wordId: (json['wordId'] as num?)?.toInt() ?? 0,
      englishWord: (json['englishWord'] as String?) ?? '',
      whatIs: _safeString(json['whatIs'] ?? json['what_is']),
      meaning: _safeString(json['meaning']),
      translations: _safeString(json['translations']),
      usage: _safeString(json['usage']),
      hint: _safeString(json['hint']),
      examples: rawExamples is List
          ? rawExamples
              .whereType<Map<String, dynamic>>()
              .map((e) => ExampleModel.fromJson(e))
              .toList()
          : [],
    );
  }

  static String? _safeString(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }
}

/// ============================
///  EXAMPLES WIDGET (UPDATED)
/// ============================
class ExamplesWidget extends StatelessWidget {
  const ExamplesWidget({
    super.key,
    required this.examples,
  });

  final List<ExampleModel> examples;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: examples.map((example) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                example.text,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  height: 1.4,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                example.translation,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.4,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}