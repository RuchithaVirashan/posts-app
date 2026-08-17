import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:postsapp/core/storage/secure_storage_service.dart';
import 'package:postsapp/data/datasources/local/auth_local_data_source.dart';
import 'package:postsapp/data/models/user_model.dart';

class _MockSecureStorageService extends Mock implements SecureStorageService {}

void main() {
  late _MockSecureStorageService mockStorage;
  late AuthLocalDataSourceImpl dataSource;

  const user = UserModel(id: 1, username: 'emilys', email: 'e@x.com');

  setUp(() {
    mockStorage = _MockSecureStorageService();
    dataSource = AuthLocalDataSourceImpl(mockStorage);
  });

  group('AuthLocalDataSourceImpl', () {
    test('saveSession_writesTokenAndSerializedUser', () async {
      when(() => mockStorage.saveToken(any())).thenAnswer((_) async {});
      when(() => mockStorage.saveUser(any())).thenAnswer((_) async {});

      await dataSource.saveSession(token: 'jwt', user: user);

      verify(() => mockStorage.saveToken('jwt')).called(1);
      verify(
        () => mockStorage.saveUser(
          '{"id":1,"username":"emilys","email":"e@x.com","firstName":null,"lastName":null,"image":null}',
        ),
      ).called(1);
    });

    test('getToken_delegatesToStorage', () async {
      when(() => mockStorage.getToken()).thenAnswer((_) async => 'jwt');

      final token = await dataSource.getToken();

      expect(token, 'jwt');
    });

    test('getCachedUser_withStoredJson_returnsDeserializedUser', () async {
      when(() => mockStorage.readUser()).thenAnswer(
        (_) async => '{"id":1,"username":"emilys","email":"e@x.com"}',
      );

      final cached = await dataSource.getCachedUser();

      expect(cached, isNotNull);
      expect(cached!.username, 'emilys');
    });

    test('getCachedUser_withNothingStored_returnsNull', () async {
      when(() => mockStorage.readUser()).thenAnswer((_) async => null);

      final cached = await dataSource.getCachedUser();

      expect(cached, isNull);
    });

    test('clearSession_delegatesToStorageClear', () async {
      when(() => mockStorage.clear()).thenAnswer((_) async {});

      await dataSource.clearSession();

      verify(() => mockStorage.clear()).called(1);
    });
  });
}
