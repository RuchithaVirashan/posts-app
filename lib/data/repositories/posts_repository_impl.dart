import '../../core/error/failures.dart';
import '../../core/error/result.dart';
import '../../domain/entities/posts_page.dart';
import '../../domain/repositories/posts_repository.dart';
import '../datasources/remote/posts_remote_data_source.dart';

class PostsRepositoryImpl implements PostsRepository {
  PostsRepositoryImpl({required PostsRemoteDataSource remote})
    : _remote = remote;

  final PostsRemoteDataSource _remote;

  @override
  Future<Result<PostsPage>> fetchPosts({
    required int skip,
    required int limit,
    String? query,
  }) async {
    try {
      final page = await _remote.fetchPosts(
        skip: skip,
        limit: limit,
        query: query,
      );
      return Ok(
        PostsPage(posts: page.posts, total: page.total, hasMore: page.hasMore),
      );
    } on Failure catch (failure) {
      return Err(failure);
    } catch (_) {
      return const Err(UnknownFailure());
    }
  }
}
