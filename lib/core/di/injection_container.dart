import 'package:get_it/get_it.dart';

import '../../data/datasources/local/auth_local_data_source.dart';
import '../../data/datasources/remote/auth_remote_data_source.dart';
import '../../data/datasources/remote/posts_remote_data_source.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/posts_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/posts_repository.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/dashboard/bloc/posts_bloc.dart';
import '../network/dio_client.dart';
import '../storage/secure_storage_service.dart';

final GetIt sl = GetIt.instance;

void setupDependencies() {
  sl.registerLazySingleton<SecureStorageService>(SecureStorageService.new);
  sl.registerLazySingleton<DioClient>(
    () => DioClient(tokenProvider: sl<SecureStorageService>()),
  );

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sl<SecureStorageService>()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remote: sl<AuthRemoteDataSource>(),
      local: sl<AuthLocalDataSource>(),
    ),
  );

  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );

  sl.registerLazySingleton<PostsRemoteDataSource>(
    () => PostsRemoteDataSourceImpl(sl<DioClient>()),
  );
  sl.registerLazySingleton<PostsRepository>(
    () => PostsRepositoryImpl(remote: sl<PostsRemoteDataSource>()),
  );

  sl.registerFactory<PostsBloc>(
    () => PostsBloc(postsRepository: sl<PostsRepository>()),
  );
}
