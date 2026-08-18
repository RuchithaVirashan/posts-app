import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/data/models/post_model.dart';

void main() {
  group('PostModel.fromJson', () {
    test('fromJson_withFullPayload_returnsPopulatedModel', () {
      final json = {
        'id': 1,
        'userId': 42,
        'title': 'Post title',
        'body': 'Post body',
        'tags': ['history', 'american'],
        'reactions': {'likes': 10, 'dislikes': 2},
      };

      final post = PostModel.fromJson(json);

      expect(post.id, 1);
      expect(post.userId, 42);
      expect(post.title, 'Post title');
      expect(post.body, 'Post body');
      expect(post.tags, ['history', 'american']);
      expect(post.likes, 10);
      expect(post.dislikes, 2);
    });

    test('fromJson_withoutTagsOrReactions_defaultsToEmptyAndZero', () {
      final json = {
        'id': 1,
        'userId': 42,
        'title': 'Post title',
        'body': 'Post body',
      };

      final post = PostModel.fromJson(json);

      expect(post.tags, isEmpty);
      expect(post.likes, 0);
      expect(post.dislikes, 0);
    });

    test('fromJson_withMissingRequiredField_throwsTypeError', () {
      final json = {'userId': 42, 'title': 'Post title', 'body': 'Post body'};

      expect(() => PostModel.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
