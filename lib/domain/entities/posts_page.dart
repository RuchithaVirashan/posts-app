import 'package:equatable/equatable.dart';

import 'post.dart';

class PostsPage extends Equatable {
  const PostsPage({
    required this.posts,
    required this.total,
    required this.hasMore,
  });

  final List<Post> posts;
  final int total;
  final bool hasMore;

  @override
  List<Object?> get props => [posts, total, hasMore];
}
