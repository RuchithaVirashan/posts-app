import 'post_model.dart';

class PostsPageModel {
  const PostsPageModel({
    required this.posts,
    required this.total,
    required this.skip,
  });

  final List<PostModel> posts;
  final int total;
  final int skip;

  factory PostsPageModel.fromJson(Map<String, dynamic> json) {
    final postsJson = json['posts'] as List<dynamic>? ?? const [];
    return PostsPageModel(
      posts: postsJson
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      total: json['total'] as int? ?? 0,
      skip: json['skip'] as int? ?? 0,
    );
  }

  bool get hasMore => skip + posts.length < total;
}
