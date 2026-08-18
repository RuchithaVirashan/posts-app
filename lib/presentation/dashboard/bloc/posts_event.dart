import 'package:equatable/equatable.dart';

sealed class PostsEvent extends Equatable {
  const PostsEvent();

  @override
  List<Object?> get props => [];
}

final class PostsStarted extends PostsEvent {
  const PostsStarted();
}

final class PostsSearchChanged extends PostsEvent {
  const PostsSearchChanged(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

final class PostsRefreshRequested extends PostsEvent {
  const PostsRefreshRequested();
}

final class PostsNextPageRequested extends PostsEvent {
  const PostsNextPageRequested();
}
