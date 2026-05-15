import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'category_model.dart';

final categoriesApiProvider = Provider<CategoriesApi>((ref) {
  return CategoriesApi(ref.watch(dioProvider));
});

class CategoriesApi {
  const CategoriesApi(this._dio);

  final Dio _dio;

  Future<List<CategoryModel>> getCategories({String? languageCode}) async {
    try {
      final response = await _dio.get(
        '/api/categories',
        queryParameters: languageCode == null ? null : {'lang': languageCode},
      );
      final data = response.data as List<dynamic>? ?? [];
      return data
          .whereType<Map<String, dynamic>>()
          .map(CategoryModel.fromJson)
          .toList();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
