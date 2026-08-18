import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/network/api_endpoints.dart';
import 'package:postsapp/core/network/dio_client.dart';
import 'package:postsapp/data/datasources/remote/posts_remote_data_source.dart';

class _MockDioClient extends Mock implements DioClient {}

void main() {
  late _MockDioClient mockClient;
  late PostsRemoteDataSourceImpl dataSource;

  setUp(() {
    mockClient = _MockDioClient();
    dataSource = PostsRemoteDataSourceImpl(mockClient);
  });

  group('PostsRemoteDataSourceImpl.fetchPosts', () {
    test('withoutQuery_hitsPostsEndpointWithSkipAndLimit', () async {
      when(
        () => mockClient.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => {'posts': [], 'total': 0, 'skip': 0, 'limit': 10});

      await dataSource.fetchPosts(skip: 20, limit: 10);

      final captured = verify(
        () => mockClient.get(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      expect(captured[0], ApiEndpoints.posts);
      expect(captured[1], {'limit': 10, 'skip': 20});
    });

    test('withQuery_hitsSearchEndpointWithQParam', () async {
      when(
        () => mockClient.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => {'posts': [], 'total': 0, 'skip': 0, 'limit': 10});

      await dataSource.fetchPosts(skip: 0, limit: 10, query: 'love');

      final captured = verify(
        () => mockClient.get(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      expect(captured[0], ApiEndpoints.postsSearch);
      expect(captured[1], {'q': 'love', 'limit': 10, 'skip': 0});
    });

    test('withBlankQuery_isTreatedAsNoQuery', () async {
      when(
        () => mockClient.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => {'posts': [], 'total': 0, 'skip': 0, 'limit': 10});

      await dataSource.fetchPosts(skip: 0, limit: 10, query: '   ');

      final captured = verify(
        () => mockClient.get(
          captureAny(),
          queryParameters: captureAny(named: 'queryParameters'),
        ),
      ).captured;

      expect(captured[0], ApiEndpoints.posts);
      expect((captured[1] as Map).containsKey('q'), isFalse);
    });

    test('onSuccess_returnsParsedPage', () async {
      when(
        () => mockClient.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer(
        (_) async => {
          'posts': [
            {'id': 1, 'userId': 1, 'title': 'A', 'body': 'A body'},
          ],
          'total': 1,
          'skip': 0,
          'limit': 10,
        },
      );

      final page = await dataSource.fetchPosts(skip: 0, limit: 10);

      expect(page.posts, hasLength(1));
      expect(page.total, 1);
    });
  });
}
