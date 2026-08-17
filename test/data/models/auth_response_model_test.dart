import 'package:flutter_test/flutter_test.dart';
import 'package:postsapp/data/models/auth_response_model.dart';

void main() {
  group('AuthResponseModel.fromJson', () {
    test('fromJson_withLoginPayload_splitsUserAndToken', () {
      final json = {
        'id': 1,
        'username': 'emilys',
        'email': 'emily.johnson@x.dummyjson.com',
        'firstName': 'Emily',
        'lastName': 'Johnson',
        'image': 'img.png',
        'accessToken': 'jwt-access',
        'refreshToken': 'jwt-refresh',
      };

      final response = AuthResponseModel.fromJson(json);

      expect(response.accessToken, 'jwt-access');
      expect(response.user.id, 1);
      expect(response.user.username, 'emilys');
    });

    test('fromJson_withoutAccessToken_throwsTypeError', () {
      final json = {'id': 1, 'username': 'emilys', 'email': 'e@x.com'};

      expect(() => AuthResponseModel.fromJson(json), throwsA(isA<TypeError>()));
    });
  });
}
