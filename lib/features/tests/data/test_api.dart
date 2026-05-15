import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'test_models.dart';

final testApiProvider = Provider<TestApi>((ref) {
  return TestApi(ref.watch(dioProvider));
});

class TestApi {
  const TestApi(this._dio);

  final Dio _dio;

  Future<StartTestResponse> startTest(StartTestRequest request) async {
    try {
      final response = await _dio.post(
        '/api/tests/start',
        data: request.toJson(),
      );
      return StartTestResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<SubmitAnswerResponse> submitAnswer(SubmitAnswerRequest request) async {
    try {
      final response = await _dio.post(
        '/api/tests/answer',
        data: request.toJson(),
      );
      return SubmitAnswerResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<FinishTestResponse> finishTest(int testSessionId) async {
    try {
      final response = await _dio.post('/api/tests/$testSessionId/finish');
      return FinishTestResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
