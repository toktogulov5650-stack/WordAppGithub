import 'package:dio/dio.dart';

class ApiException implements Exception {
  const ApiException({required this.message, this.statusCode, this.details});

  final int? statusCode;
  final String message;
  final Object? details;

  bool get isUnauthorized => statusCode == 401;
  bool get isNotFound => statusCode == 404;

  @override
  String toString() => 'ApiException($statusCode): $message';

  static ApiException fromDioException(DioException exception) {
    final statusCode = exception.response?.statusCode;
    final responseData = exception.response?.data;
    final extractedMessage = _extractMessage(responseData);

    if (exception.type == DioExceptionType.connectionTimeout ||
        exception.type == DioExceptionType.sendTimeout ||
        exception.type == DioExceptionType.receiveTimeout ||
        exception.type == DioExceptionType.connectionError) {
      return const ApiException(message: 'Интернет байланышын текшериңиз');
    }

    if (statusCode == 400) {
      return ApiException(
        statusCode: statusCode,
        message: extractedMessage ?? 'Бир нерсе туура эмес болуп кетти',
        details: responseData,
      );
    }

    if (statusCode == 401) {
      return ApiException(
        statusCode: statusCode,
        message: extractedMessage ?? 'Сессия аяктады. Кайра кириңиз',
        details: responseData,
      );
    }

    if (statusCode == 404) {
      return ApiException(
        statusCode: statusCode,
        message: extractedMessage ?? 'Маалымат табылган жок',
        details: responseData,
      );
    }

    if (statusCode != null && statusCode >= 500) {
      return ApiException(
        statusCode: statusCode,
        message: extractedMessage ?? 'Сервер убактылуу жеткиликсиз',
        details: responseData,
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: extractedMessage ?? 'Бир нерсе туура эмес болуп кетти',
      details: responseData,
    );
  }

  static String? _extractMessage(dynamic data) {
    if (data == null) {
      return null;
    }

    if (data is String && data.trim().isNotEmpty) {
      return data.trim();
    }

    if (data is Map<String, dynamic>) {
      for (final key in ['message', 'error', 'title', 'detail']) {
        final value = data[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }

      final errors = data['errors'];
      if (errors is Map<String, dynamic>) {
        final messages = <String>[];
        for (final value in errors.values) {
          if (value is List) {
            for (final item in value) {
              if (item is String && item.trim().isNotEmpty) {
                messages.add(item.trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            messages.add(value.trim());
          }
        }
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }

    return null;
  }
}
