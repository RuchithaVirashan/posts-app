import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/error/failures.dart';
import 'package:postsapp/core/error/result.dart';
import 'package:postsapp/data/models/post_model.dart';
import 'package:postsapp/domain/entities/posts_page.dart';
import 'package:postsapp/domain/repositories/posts_repository.dart';
import 'package:postsapp/presentation/dashboard/bloc/posts_bloc.dart';
import 'package:postsapp/presentation/dashboard/bloc/posts_event.dart';
import 'package:postsapp/presentation/dashboard/bloc/posts_state.dart';

class _MockPostsRepository extends Mock implements PostsRepository {}

void main() {
  late _MockPostsRepository mockRepository;

  const postA = PostModel(
    id: 1,
    userId: 1,
    title: 'A',
    body: 'A body',
    tags: [],
    likes: 0,
    dislikes: 0,
  );
  const postB = PostModel(
    id: 2,
    userId: 1,
    title: 'B',
    body: 'B body',
    tags: [],
    likes: 0,
    dislikes: 0,
  );

  setUp(() {
    mockRepository = _MockPostsRepository();
  });

  PostsBloc buildBloc() => PostsBloc(
    postsRepository: mockRepository,
    searchDebounce: const Duration(milliseconds: 10),
  );

  group('PostsStarted', () {
    blocTest<PostsBloc, PostsState>(
      'started_onSuccess_emitsLoadingThenSuccessWithPosts',
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer(
          (_) async => const Ok(
            PostsPage(posts: [postA, postB], total: 2, hasMore: false),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsStarted()),
      expect: () => [
        const PostsState(status: PostsStatus.loading),
        const PostsState(
          status: PostsStatus.success,
          posts: [postA, postB],
          skip: 2,
          hasMore: false,
        ),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'started_withEmptyResults_emitsLoadingThenEmpty',
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer(
          (_) async => const Ok(PostsPage(posts: [], total: 0, hasMore: false)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsStarted()),
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loading),
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.empty),
      ],
    );

    blocTest<PostsBloc, PostsState>(
      'started_onNetworkFailure_emitsLoadingThenFailure',
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => const Err(NetworkFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsStarted()),
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loading),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.failure)
            .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
      ],
    );
  });

  group('PostsSearchChanged', () {
    blocTest<PostsBloc, PostsState>(
      'searchChanged_debouncesRapidInput_fetchesOnlyOnceForLatestQuery',
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer(
          (_) async => const Ok(PostsPage(posts: [postA], total: 1, hasMore: false)),
        );
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const PostsSearchChanged('l'));
        bloc.add(const PostsSearchChanged('lo'));
        bloc.add(const PostsSearchChanged('lov'));
        bloc.add(const PostsSearchChanged('love'));
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.loading)
            .having((s) => s.query, 'query', 'love'),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.success)
            .having((s) => s.query, 'query', 'love'),
      ],
      verify: (_) {
        verify(
          () => mockRepository.fetchPosts(skip: 0, limit: any(named: 'limit'), query: 'love'),
        ).called(1);
        verifyNever(
          () => mockRepository.fetchPosts(skip: 0, limit: any(named: 'limit'), query: 'l'),
        );
      },
    );

    blocTest<PostsBloc, PostsState>(
      'searchThenClear_returnsToUnfilteredList',
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: 'love',
          ),
        ).thenAnswer(
          (_) async => const Ok(PostsPage(posts: [postA], total: 1, hasMore: false)),
        );
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: '',
          ),
        ).thenAnswer(
          (_) async =>
              const Ok(PostsPage(posts: [postA, postB], total: 2, hasMore: false)),
        );
        return buildBloc();
      },
      act: (bloc) async {
        bloc.add(const PostsSearchChanged('love'));
        await Future<void>.delayed(const Duration(milliseconds: 30));
        bloc.add(const PostsSearchChanged(''));
      },
      wait: const Duration(milliseconds: 50),
      skip: 2,
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loading),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.success)
            .having((s) => s.posts, 'posts', [postA, postB]),
      ],
    );
  });

  group('PostsNextPageRequested', () {
    blocTest<PostsBloc, PostsState>(
      'nextPageRequested_appendsPostsAndAdvancesSkip',
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [postA],
        skip: 1,
        hasMore: true,
      ),
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer(
          (_) async => const Ok(PostsPage(posts: [postB], total: 2, hasMore: false)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsNextPageRequested()),
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loadingMore),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.success)
            .having((s) => s.posts, 'posts', [postA, postB])
            .having((s) => s.skip, 'skip', 2)
            .having((s) => s.hasMore, 'hasMore', isFalse),
      ],
      verify: (_) {
        verify(
          () => mockRepository.fetchPosts(skip: 1, limit: any(named: 'limit'), query: ''),
        ).called(1);
      },
    );

    blocTest<PostsBloc, PostsState>(
      'nextPageRequested_whenNoMorePages_doesNotCallRepository',
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [postA, postB],
        skip: 2,
        hasMore: false,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const PostsNextPageRequested()),
      expect: () => <PostsState>[],
      verify: (_) {
        verifyNever(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        );
      },
    );

    blocTest<PostsBloc, PostsState>(
      'nextPageRequested_onFailure_keepsExistingPostsAndSurfacesFailure',
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [postA],
        skip: 1,
        hasMore: true,
      ),
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer((_) async => const Err(NetworkFailure()));
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsNextPageRequested()),
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loadingMore),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.success)
            .having((s) => s.posts, 'posts', [postA])
            .having((s) => s.failure, 'failure', isA<NetworkFailure>()),
      ],
    );
  });

  group('PostsRefreshRequested', () {
    blocTest<PostsBloc, PostsState>(
      'refreshRequested_refetchesFirstPageForCurrentQuery',
      seed: () => const PostsState(
        status: PostsStatus.success,
        posts: [postA],
        query: 'love',
        skip: 1,
        hasMore: false,
      ),
      build: () {
        when(
          () => mockRepository.fetchPosts(
            skip: any(named: 'skip'),
            limit: any(named: 'limit'),
            query: any(named: 'query'),
          ),
        ).thenAnswer(
          (_) async => const Ok(PostsPage(posts: [postB], total: 1, hasMore: false)),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const PostsRefreshRequested()),
      expect: () => [
        isA<PostsState>().having((s) => s.status, 'status', PostsStatus.loading),
        isA<PostsState>()
            .having((s) => s.status, 'status', PostsStatus.success)
            .having((s) => s.posts, 'posts', [postB]),
      ],
      verify: (_) {
        verify(
          () => mockRepository.fetchPosts(skip: 0, limit: any(named: 'limit'), query: 'love'),
        ).called(1);
      },
    );
  });
}
