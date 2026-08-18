import '../../core/error/result.dart';
import '../entities/posts_page.dart';

abstract class PostsRepository {
  Future<Result<PostsPage>> fetchPosts({
    required int skip,
    required int limit,
    String? query,
  });
}
