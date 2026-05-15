import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'word_explanation_models.dart';

final wordExplanationApiProvider = Provider<WordExplanationApi>((ref) {
  return WordExplanationApi(ref.watch(dioProvider));
});

class WordExplanationApi {
  const WordExplanationApi(this._dio);

  final Dio _dio;

  Future<List<UnknownWordModel>> getUnknownWords(
    int testSessionId, {
    String? languageCode,
  }) async {
    try {
      final response = await _dio.get(
        '/api/word-explanations/tests/$testSessionId/unknown-words',
        queryParameters: languageCode == null ? null : {'lang': languageCode},
      );
      final data = response.data as List<dynamic>? ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(UnknownWordModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<WordExplanationModel> getWordExplanation(
    int wordId, {
    String? languageCode,
  }) async {
    try {
      final response = await _dio.get(
        '/api/word-explanations/words/$wordId',
        queryParameters: languageCode == null ? null : {'lang': languageCode},
      );
      return WordExplanationModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<List<WordByCategoryModel>> getWordsByCategory(
    int categoryId, {
    String? languageCode,
  }) async {
    try {
      final response = await _dio.get(
        '/api/word-explanations/categories/$categoryId',
        queryParameters: languageCode == null ? null : {'lang': languageCode},
      );
      final data = response.data;
      if (data is! List) {
        return const [];
      }

      return data
          .whereType<Map<String, dynamic>>()
          .map(WordByCategoryModel.fromJson)
          .where((item) => item.wordId != 0 && item.englishWord.isNotEmpty)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
