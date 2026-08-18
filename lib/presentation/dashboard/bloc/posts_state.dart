import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../domain/entities/post.dart';

enum PostsStatus { initial, loading, loadingMore, success, empty, failure }

class PostsState extends Equatable {
  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const [],
    this.query = '',
    this.skip = 0,
    this.hasMore = true,
    this.failure,
  });

  final PostsStatus status;
  final List<Post> posts;
  final String query;
  final int skip;
  final bool hasMore;
  final Failure? failure;

  PostsState copyWith({
    PostsStatus? status,
    List<Post>? posts,
    String? query,
    int? skip,
    bool? hasMore,
    Failure? failure,
    bool clearFailure = false,
  }) {
    return PostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      query: query ?? this.query,
      skip: skip ?? this.skip,
      hasMore: hasMore ?? this.hasMore,
      failure: clearFailure ? null : (failure ?? this.failure),
    );
  }

  @override
  List<Object?> get props => [status, posts, query, skip, hasMore, failure];
}
