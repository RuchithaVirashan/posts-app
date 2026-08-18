import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/data/datasources/remote/posts_remote_data_source.dart';
import 'package:postsapp/data/models/post_model.dart';
import 'package:postsapp/data/models/posts_page_model.dart';
import 'package:postsapp/data/repositories/posts_repository_impl.dart';

class _MockPostsRemoteDataSource extends Mock implements PostsRemoteDataSource {}

void main() {
  late _MockPostsRemoteDataSource mockRemote;
  late PostsRepositoryImpl repository;

  const post = PostModel(
    id: 1,
    userId: 1,
    title: 'A',
    body: 'A body',
    tags: [],
    likes: 0,
    dislikes: 0,
  );

  setUp(() {
    mockRemote = _MockPostsRemoteDataSource();
    repository = PostsRepositoryImpl(remote: mockRemote);
  });

  group('fetchPosts', () {
    test('fetchPosts_onSuccess_returnsPostsPageWithHasMoreTrue', () async {
      when(
        () => mockRemote.fetchPosts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ).thenAnswer(
        (_) async => const PostsPageModel(posts: [post], total: 251, skip: 0),
      );

      final result = await repository.fetchPosts(skip: 0, limit: 10);

      result.when(
        ok: (page) {
          expect(page.posts, hasLength(1));
          expect(page.total, 251);
          expect(page.hasMore, isTrue);
        },
        err: (_) => fail('expected Ok'),
      );
    });

    test('fetchPosts_onLastPage_returnsHasMoreFalse', () async {
      when(
        () => mockRemote.fetchPosts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ).thenAnswer(
        (_) async => const PostsPageModel(posts: [post], total: 1, skip: 0),
      );

      final result = await repository.fetchPosts(skip: 0, limit: 10);

      result.when(
        ok: (page) => expect(page.hasMore, isFalse),
        err: (_) => fail('expected Ok'),
      );
    });

    test('fetchPosts_withNoMatches_returnsOkWithEmptyList', () async {
      when(
        () => mockRemote.fetchPosts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ).thenAnswer(
        (_) async => const PostsPageModel(posts: [], total: 0, skip: 0),
      );

      final result = await repository.fetchPosts(
        skip: 0,
        limit: 10,
        query: 'nonexistent',
      );

      result.when(
        ok: (page) => expect(page.posts, isEmpty),
        err: (_) => fail('expected Ok, not an error, for zero matches'),
      );
    });

    test('fetchPosts_onNetworkFailure_returnsErrWithFailure', () async {
      when(
        () => mockRemote.fetchPosts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ).thenThrow(const NetworkFailure());

      final result = await repository.fetchPosts(skip: 0, limit: 10);

      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<NetworkFailure>()),
      );
    });

    test('fetchPosts_onUnexpectedException_returnsUnknownFailure', () async {
      when(
        () => mockRemote.fetchPosts(
          skip: any(named: 'skip'),
          limit: any(named: 'limit'),
          query: any(named: 'query'),
        ),
      ).thenThrow(Exception('boom'));

      final result = await repository.fetchPosts(skip: 0, limit: 10);

      result.when(
        ok: (_) => fail('expected Err'),
        err: (failure) => expect(failure, isA<UnknownFailure>()),
      );
    });
  });
}
