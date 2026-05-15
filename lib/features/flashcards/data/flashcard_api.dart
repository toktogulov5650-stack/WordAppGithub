import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'flashcard_model.dart';

final flashcardApiProvider = Provider<FlashcardApi>((ref) {
  return FlashcardApi(ref.watch(dioProvider));
});

class FlashcardApi {
  const FlashcardApi(this._dio);

  final Dio _dio;

  Future<FlashcardModel> getRandomFlashcard({
    int? excludeWordId,
    String? languageCode,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'excludeWordId': excludeWordId,
        'lang': languageCode,
      }..removeWhere((_, value) => value == null);

      final response = await _dio.get(
        '/api/flashcards/random',
        queryParameters: queryParameters.isEmpty ? null : queryParameters,
      );

      return FlashcardModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
