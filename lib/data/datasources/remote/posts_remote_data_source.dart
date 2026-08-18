import '../../../core/network/api_endpoints.dart';
import '../../../core/network/dio_client.dart';
import '../../models/posts_page_model.dart';

abstract class PostsRemoteDataSource {
  Future<PostsPageModel> fetchPosts({
    required int skip,
    required int limit,
    String? query,
  });
}

class PostsRemoteDataSourceImpl implements PostsRemoteDataSource {
  PostsRemoteDataSourceImpl(this._client);

  final DioClient _client;

  @override
  Future<PostsPageModel> fetchPosts({
    required int skip,
    required int limit,
    String? query,
  }) async {
    final trimmedQuery = query?.trim();
    final hasQuery = trimmedQuery != null && trimmedQuery.isNotEmpty;

    final json = await _client.get(
      hasQuery ? ApiEndpoints.postsSearch : ApiEndpoints.posts,
      queryParameters: {
        if (hasQuery) 'q': trimmedQuery,
        'limit': limit,
        'skip': skip,
      },
    );
    return PostsPageModel.fromJson(json);
  }
}
