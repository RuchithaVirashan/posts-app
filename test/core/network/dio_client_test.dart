import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/network/dio_client.dart';
import 'package:postsapp/core/network/token_provider.dart';

class _FakeTokenProvider implements TokenProvider {
  _FakeTokenProvider(this._token);

  final String? _token;

  @override
  Future<String?> getToken() async => _token;
}

class _FakeHttpClientAdapter implements HttpClientAdapter {
  _FakeHttpClientAdapter(this._handler);

  final ResponseBody Function(RequestOptions options) _handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return _handler(options);
  }
}

Dio _dioWithAdapter(ResponseBody Function(RequestOptions options) handler) {
  final dio = Dio();
  dio.httpClientAdapter = _FakeHttpClientAdapter(handler);
  return dio;
}

ResponseBody _jsonResponse(Object data, int statusCode) {
  return ResponseBody.fromString(
    jsonEncode(data),
    statusCode,
    headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    },
  );
}

void main() {
  group('DioClient.get', () {
    test('withTokenAvailable_attachesAuthorizationHeader', () async {
      RequestOptions? captured;
      final dio = _dioWithAdapter((options) {
        captured = options;
        return _jsonResponse({'ok': true}, 200);
      });
      final client = DioClient(
        tokenProvider: _FakeTokenProvider('abc123'),
        dio: dio,
      );

      await client.get('/things');

      expect(captured?.headers['Authorization'], 'Bearer abc123');
    });

    test('withoutToken_omitsAuthorizationHeader', () async {
      RequestOptions? captured;
      final dio = _dioWithAdapter((options) {
        captured = options;
        return _jsonResponse({'ok': true}, 200);
      });
      final client = DioClient(
        tokenProvider: _FakeTokenProvider(null),
        dio: dio,
      );

      await client.get('/things');

      expect(captured?.headers.containsKey('Authorization'), isFalse);
    });

    test('onSuccess_returnsDecodedMap', () async {
      final dio = _dioWithAdapter(
        (_) => _jsonResponse({'id': 1, 'title': 'Hello'}, 200),
      );
      final client = DioClient(
        tokenProvider: _FakeTokenProvider(null),
        dio: dio,
      );

      final result = await client.get('/posts/1');

      expect(result, {'id': 1, 'title': 'Hello'});
    });

    test('on404_throwsServerFailureWithStatusCode', () async {
      final dio = _dioWithAdapter(
        (_) => _jsonResponse({'message': 'Not found'}, 404),
      );
      final client = DioClient(
        tokenProvider: _FakeTokenProvider(null),
        dio: dio,
      );

      await expectLater(
        client.get('/posts/999'),
        throwsA(
          isA<ServerFailure>().having((f) => f.statusCode, 'statusCode', 404),
        ),
      );
    });
  });

  group('DioClient.post', () {
    test('on400_throwsValidationFailureWithServerMessage', () async {
      final dio = _dioWithAdapter(
        (_) => _jsonResponse({'message': 'Invalid credentials'}, 400),
      );
      final client = DioClient(
        tokenProvider: _FakeTokenProvider(null),
        dio: dio,
      );

      await expectLater(
        client.post('/auth/login', data: {'username': 'x', 'password': 'y'}),
        throwsA(
          isA<ValidationFailure>().having(
            (f) => f.message,
            'message',
            'Invalid credentials',
          ),
        ),
      );
    });

    test('onSuccess_sendsProvidedBody', () async {
      RequestOptions? captured;
      final dio = _dioWithAdapter((options) {
        captured = options;
        return _jsonResponse({'accessToken': 'token'}, 200);
      });
      final client = DioClient(
        tokenProvider: _FakeTokenProvider(null),
        dio: dio,
      );

      await client.post(
        '/auth/login',
        data: {'username': 'emilys', 'password': 'emilyspass'},
      );

      expect(captured?.data, {'username': 'emilys', 'password': 'emilyspass'});
    });
  });
}
