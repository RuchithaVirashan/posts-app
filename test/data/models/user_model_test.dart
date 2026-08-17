import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/data/models/user_model.dart';

void main() {
  group('UserModel.fromJson', () {
    test('fromJson_withFullPayload_returnsPopulatedModel', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'https://dummyjson.com/icon/emilys/128',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 1);
      expect(user.username, 'emilys');
      expect(user.email, 'emily.johnson@x.dummyjson.com');
      expect(user.firstName, 'Emily');
      expect(user.lastName, 'Johnson');
      expect(user.image, 'https://dummyjson.com/icon/emilys/128');
    });

    test('fromJson_withMissingOptionalFields_returnsNullsForThem', () {
      final json = {'id': 2, 'username': 'michaelw', 'email': 'm@x.com'};

      final user = UserModel.fromJson(json);

      expect(user.firstName, isNull);
      expect(user.lastName, isNull);
      expect(user.image, isNull);
    });

    test('fromJson_withMissingRequiredField_throwsTypeError', () {
      final json = {'username': 'emilys', 'email': 'e@x.com'};

      expect(() => UserModel.fromJson(json), throwsA(isA<TypeError>()));
    });
  });

  group('UserModel.toJson', () {
    test('toJson_roundTripsThroughFromJson', () {
      const user = UserModel(
        id: 1,
        username: 'emilys',
        email: 'e@x.com',
        firstName: 'Emily',
        lastName: 'Johnson',
        image: 'img.png',
      );

      final roundTripped = UserModel.fromJson(user.toJson());

      expect(roundTripped, user);
    });
  });

  group('User.displayName', () {
    test('displayName_withFirstAndLastName_returnsFullName', () {
      const user = UserModel(
        id: 1,
        username: 'emilys',
        email: 'e@x.com',
        firstName: 'Emily',
        lastName: 'Johnson',
      );

      expect(user.displayName, 'Emily Johnson');
    });

    test('displayName_withoutNames_fallsBackToUsername', () {
      const user = UserModel(id: 1, username: 'emilys', email: 'e@x.com');

      expect(user.displayName, 'emilys');
    });
  });
}
