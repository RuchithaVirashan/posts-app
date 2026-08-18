import '../../domain/entities/post.dart';

class PostModel extends Post {
  const PostModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.body,
    required super.tags,
    required super.likes,
    required super.dislikes,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    final reactions = json['reactions'];
    final reactionsMap = reactions is Map<String, dynamic>
        ? reactions
        : const <String, dynamic>{};

    return PostModel(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      body: json['body'] as String,
      tags: (json['tags'] as List<dynamic>? ?? const [])
          .map((e) => e as String)
          .toList(),
      likes: reactionsMap['likes'] as int? ?? 0,
      dislikes: reactionsMap['dislikes'] as int? ?? 0,
    );
  }
}
