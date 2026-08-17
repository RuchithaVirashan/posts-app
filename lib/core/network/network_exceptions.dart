import 'package:dio/dio.dart';

import '../error/failures.dart';

Failure mapDioExceptionToFailure(DioException exception) {
  switch (exception.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.connectionError:
    case DioExceptionType.transformTimeout:
      return const NetworkFailure();
    case DioExceptionType.badCertificate:
      return const NetworkFailure(
        'A secure connection could not be established.',
      );
    case DioExceptionType.cancel:
      return const UnknownFailure('The request was cancelled.');
    case DioExceptionType.badResponse:
      return _mapBadResponse(exception);
    case DioExceptionType.unknown:
      if (exception.error is FormatException) {
        return const UnknownFailure(
          'The server returned an unexpected response.',
        );
      }
      return const NetworkFailure();
  }
}

Failure _mapBadResponse(DioException exception) {
  final statusCode = exception.response?.statusCode;
  final message = _extractServerMessage(exception.response?.data);

  if (statusCode == 401) {
    return UnauthorizedFailure(
      message ?? 'Session expired. Please log in again.',
    );
  }
  if (statusCode == 400) {
    return ValidationFailure(message ?? 'Invalid request.');
  }
  if (statusCode == 404) {
    return ServerFailure(message ?? 'Not found.', statusCode: statusCode);
  }
  if (statusCode != null && statusCode >= 500) {
    return ServerFailure(
      message ?? 'Server error. Please try again later.',
      statusCode: statusCode,
    );
  }
  return ServerFailure(message ?? 'Request failed.', statusCode: statusCode);
}

String? _extractServerMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'];
    if (message is String && message.isNotEmpty) return message;
  }
  return null;
}
