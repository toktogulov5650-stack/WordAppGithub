import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'record_model.dart';

final recordApiProvider = Provider<RecordApi>((ref) {
  return RecordApi(ref.watch(dioProvider));
});

class RecordApi {
  const RecordApi(this._dio);

  final Dio _dio;

  Future<CategoryRecordModel> getCategoryRecord(int categoryId) async {
    try {
      final response = await _dio.get('/api/records/categories/$categoryId');
      return CategoryRecordModel.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
