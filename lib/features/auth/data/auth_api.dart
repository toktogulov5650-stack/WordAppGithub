import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_exception.dart';
import '../../../core/network/dio_client.dart';
import 'auth_models.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  return AuthApi(ref.watch(dioProvider));
});

class AuthApi {
  const AuthApi(this._dio);

  final Dio _dio;

  Future<AuthResponse> register(RegisterRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<AuthResponse> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<AuthResponse> googleLogin(GoogleLoginRequest request) async {
    try {
      final response = await _dio.post(
        '/api/auth/google',
        data: request.toJson(),
      );
      return AuthResponse.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dio.get('/api/auth/me');
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }

  Future<UserModel> updateLanguage(String languageCode) async {
    try {
      final response = await _dio.put(
        '/api/auth/language',
        data: {'languageCode': languageCode},
      );
      final data = response.data;
      if (data is Map<String, dynamic> && data['user'] is Map<String, dynamic>) {
        return UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      if (data is Map<String, dynamic>) {
        return UserModel.fromJson(data);
      }
      return getCurrentUser();
    } on DioException catch (error) {
      throw ApiException.fromDioException(error);
    }
  }
}
