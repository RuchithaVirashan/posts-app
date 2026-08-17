import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/network/network_exceptions.dart';

void main() {
  final requestOptions = RequestOptions(path: '/test');

  group('mapDioExceptionToFailure', () {
    test('connectionTimeout_returnsNetworkFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionTimeout,
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });

    test('connectionError_returnsNetworkFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.connectionError,
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });

    test('badCertificate_returnsNetworkFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badCertificate,
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });

    test('cancel_returnsUnknownFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.cancel,
      );

      expect(mapDioExceptionToFailure(exception), isA<UnknownFailure>());
    });

    test('badResponseWith401_returnsUnauthorizedFailureWithServerMessage', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 401,
          data: {'message': 'Invalid token'},
        ),
      );

      final failure = mapDioExceptionToFailure(exception);

      expect(failure, isA<UnauthorizedFailure>());
      expect(failure.message, 'Invalid token');
    });

    test('badResponseWith400_returnsValidationFailureWithServerMessage', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: requestOptions,
          statusCode: 400,
          data: {'message': 'Invalid credentials'},
        ),
      );

      final failure = mapDioExceptionToFailure(exception);

      expect(failure, isA<ValidationFailure>());
      expect(failure.message, 'Invalid credentials');
    });

    test('badResponseWith404_returnsServerFailureWithStatusCode', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 404),
      );

      final failure = mapDioExceptionToFailure(exception) as ServerFailure;

      expect(failure.statusCode, 404);
    });

    test('badResponseWith500_returnsServerFailureWithStatusCode', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 500),
      );

      final failure = mapDioExceptionToFailure(exception) as ServerFailure;

      expect(failure.statusCode, 500);
    });

    test('badResponseWithoutServerMessage_usesDefaultMessage', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.badResponse,
        response: Response(requestOptions: requestOptions, statusCode: 418),
      );

      final failure = mapDioExceptionToFailure(exception);

      expect(failure.message, 'Request failed.');
    });

    test('unknownWithFormatException_returnsUnknownFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
        error: const FormatException('Unexpected character'),
      );

      expect(mapDioExceptionToFailure(exception), isA<UnknownFailure>());
    });

    test('unknownWithoutFormatException_returnsNetworkFailure', () {
      final exception = DioException(
        requestOptions: requestOptions,
        type: DioExceptionType.unknown,
      );

      expect(mapDioExceptionToFailure(exception), isA<NetworkFailure>());
    });
  });
}
