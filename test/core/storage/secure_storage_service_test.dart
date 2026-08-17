import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/storage/secure_storage_service.dart';

class _MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late _MockFlutterSecureStorage mockStorage;
  late SecureStorageService service;

  setUp(() {
    mockStorage = _MockFlutterSecureStorage();
    service = SecureStorageService(storage: mockStorage);
  });

  group('SecureStorageService', () {
    test('saveToken_writesUnderTokenKey', () async {
      when(
        () => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((_) async {});

      await service.saveToken('jwt-123');

      verify(
        () => mockStorage.write(key: 'auth_token', value: 'jwt-123'),
      ).called(1);
    });

    test('getToken_returnsStoredToken', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => 'jwt-123');

      final token = await service.getToken();

      expect(token, 'jwt-123');
    });

    test('getToken_whenNothingStored_returnsNull', () async {
      when(
        () => mockStorage.read(key: 'auth_token'),
      ).thenAnswer((_) async => null);

      final token = await service.getToken();

      expect(token, isNull);
    });

    test('saveUser_writesUnderUserKey', () async {
      when(
        () => mockStorage.write(key: any(named: 'key'), value: any(named: 'value')),
      ).thenAnswer((_) async {});

      await service.saveUser('{"id":1}');

      verify(
        () => mockStorage.write(key: 'auth_user', value: '{"id":1}'),
      ).called(1);
    });

    test('readUser_returnsStoredUserJson', () async {
      when(
        () => mockStorage.read(key: 'auth_user'),
      ).thenAnswer((_) async => '{"id":1}');

      final user = await service.readUser();

      expect(user, '{"id":1}');
    });

    test('clear_deletesBothTokenAndUserKeys', () async {
      when(
        () => mockStorage.delete(key: any(named: 'key')),
      ).thenAnswer((_) async {});

      await service.clear();

      verify(() => mockStorage.delete(key: 'auth_token')).called(1);
      verify(() => mockStorage.delete(key: 'auth_user')).called(1);
    });
  });
}
