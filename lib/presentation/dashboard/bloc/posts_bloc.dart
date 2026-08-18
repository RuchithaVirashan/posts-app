import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stream_transform/stream_transform.dart';

import '../../../core/config/app_config.dart';
import '../../../domain/repositories/posts_repository.dart';
import 'posts_event.dart';
import 'posts_state.dart';

EventTransformer<E> _debounceRestartable<E>(Duration duration) {
  return (events, mapper) => restartable<E>()(events.debounce(duration), mapper);
}

class PostsBloc extends Bloc<PostsEvent, PostsState> {
  PostsBloc({required PostsRepository postsRepository, Duration? searchDebounce})
    : _repository = postsRepository,
      _limit = AppConfig.paginationLimit,
      super(const PostsState()) {
    on<PostsStarted>(_onStarted);
    on<PostsRefreshRequested>(_onRefreshRequested);
    on<PostsNextPageRequested>(_onNextPageRequested);
    on<PostsSearchChanged>(
      _onSearchChanged,
      transformer: _debounceRestartable(
        searchDebounce ??
            Duration(milliseconds: AppConfig.searchDebounceMs),
      ),
    );
  }

  final PostsRepository _repository;
  final int _limit;

  Future<void> _onStarted(PostsStarted event, Emitter<PostsState> emit) {
    return _fetchFirstPage(emit, query: state.query);
  }

  Future<void> _onRefreshRequested(
    PostsRefreshRequested event,
    Emitter<PostsState> emit,
  ) {
    return _fetchFirstPage(emit, query: state.query);
  }

  Future<void> _onSearchChanged(
    PostsSearchChanged event,
    Emitter<PostsState> emit,
  ) {
    return _fetchFirstPage(emit, query: event.query);
  }

  Future<void> _fetchFirstPage(
    Emitter<PostsState> emit, {
    required String query,
  }) async {
    emit(
      state.copyWith(
        status: PostsStatus.loading,
        query: query,
        skip: 0,
        clearFailure: true,
      ),
    );
    final result = await _repository.fetchPosts(
      skip: 0,
      limit: _limit,
      query: query,
    );
    result.when(
      ok: (page) => emit(
        state.copyWith(
          status: page.posts.isEmpty ? PostsStatus.empty : PostsStatus.success,
          posts: page.posts,
          skip: page.posts.length,
          hasMore: page.hasMore,
          clearFailure: true,
        ),
      ),
      err: (failure) =>
          emit(state.copyWith(status: PostsStatus.failure, failure: failure)),
    );
  }

  Future<void> _onNextPageRequested(
    PostsNextPageRequested event,
    Emitter<PostsState> emit,
  ) async {
    if (!state.hasMore ||
        state.status == PostsStatus.loadingMore ||
        state.status == PostsStatus.loading) {
      return;
    }

    emit(state.copyWith(status: PostsStatus.loadingMore, clearFailure: true));
    final result = await _repository.fetchPosts(
      skip: state.skip,
      limit: _limit,
      query: state.query,
    );
    result.when(
      ok: (page) => emit(
        state.copyWith(
          status: PostsStatus.success,
          posts: [...state.posts, ...page.posts],
          skip: state.skip + page.posts.length,
          hasMore: page.hasMore,
          clearFailure: true,
        ),
      ),
      err: (failure) =>
          emit(state.copyWith(status: PostsStatus.success, failure: failure)),
    );
  }
}
