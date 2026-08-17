abstract final class ApiEndpoints {
  static const String login = '/auth/login';
  static const String posts = '/posts';
  static const String postsSearch = '/posts/search';

  static String postById(int id) => '/posts/$id';
}
