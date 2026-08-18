import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/data/models/posts_page_model.dart';

void main() {
  group('PostsPageModel.fromJson', () {
    test('fromJson_withPostsPayload_parsesAllPosts', () {
      final json = {
        'posts': [
          {'id': 1, 'userId': 1, 'title': 'A', 'body': 'A body'},
          {'id': 2, 'userId': 1, 'title': 'B', 'body': 'B body'},
        ],
        'total': 251,
        'skip': 0,
        'limit': 10,
      };

      final page = PostsPageModel.fromJson(json);

      expect(page.posts, hasLength(2));
      expect(page.total, 251);
      expect(page.skip, 0);
    });

    test('fromJson_withEmptyPostsList_isNotTreatedAsError', () {
      final json = {'posts': [], 'total': 0, 'skip': 0, 'limit': 10};

      final page = PostsPageModel.fromJson(json);

      expect(page.posts, isEmpty);
      expect(page.total, 0);
    });
  });

  group('PostsPageModel.hasMore', () {
    test('hasMore_whenSkipPlusPostsLessThanTotal_isTrue', () {
      final page = PostsPageModel.fromJson({
        'posts': List.generate(
          10,
          (i) => {'id': i, 'userId': 1, 'title': 't', 'body': 'b'},
        ),
        'total': 251,
        'skip': 0,
      });

      expect(page.hasMore, isTrue);
    });

    test('hasMore_whenSkipPlusPostsEqualsTotal_isFalse', () {
      final page = PostsPageModel.fromJson({
        'posts': List.generate(1, (i) => {'id': i, 'userId': 1, 'title': 't', 'body': 'b'}),
        'total': 251,
        'skip': 250,
      });

      expect(page.hasMore, isFalse);
    });

    test('hasMore_whenNoResults_isFalse', () {
      final page = PostsPageModel.fromJson({'posts': [], 'total': 0, 'skip': 0});

      expect(page.hasMore, isFalse);
    });
  });
}
