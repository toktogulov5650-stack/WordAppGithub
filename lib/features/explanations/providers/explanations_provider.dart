import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/language/language_provider.dart';
import '../../../core/network/api_exception.dart';
import '../data/word_explanation_api.dart';
import '../data/word_explanation_models.dart';

final unknownWordsProvider = FutureProvider.family<List<UnknownWordModel>, int>(
  (ref, testSessionId) async {
    final languageCode = ref.watch(languageProvider).languageCode;
    return ref
        .read(wordExplanationApiProvider)
        .getUnknownWords(testSessionId, languageCode: languageCode);
  },
);

final wordsByCategoryProvider =
    FutureProvider.family<List<WordByCategoryModel>, int>((
      ref,
      categoryId,
    ) async {
      final languageCode = ref.watch(languageProvider).languageCode;
      try {
        return ref
            .read(wordExplanationApiProvider)
            .getWordsByCategory(categoryId, languageCode: languageCode);
      } on ApiException catch (error) {
        if (error.isNotFound) {
          return const [];
        }
        rethrow;
      }
    });

final wordExplanationProvider =
    FutureProvider.family<WordExplanationModel?, int>((ref, wordId) async {
      final languageCode = ref.watch(languageProvider).languageCode;
      try {
        return ref
            .read(wordExplanationApiProvider)
            .getWordExplanation(wordId, languageCode: languageCode);
      } on ApiException catch (error) {
        if (error.isNotFound) {
          return null;
        }
        rethrow;
      }
    });
