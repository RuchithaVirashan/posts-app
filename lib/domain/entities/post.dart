import 'package:equatable/equatable.dart';

class Post extends Equatable {
  const Post({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.tags,
    required this.likes,
    required this.dislikes,
  });

  final int id;
  final int userId;
  final String title;
  final String body;
  final List<String> tags;
  final int likes;
  final int dislikes;

  @override
  List<Object?> get props => [id, userId, title, body, tags, likes, dislikes];
}
