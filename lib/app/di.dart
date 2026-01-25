import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/discover/data/datasources/ooh_remote_datasource.dart';
import '../features/discover/data/repositories/ooh_repository_impl.dart';
import '../features/discover/domain/repositories/ooh_repository.dart';
import '../features/discover/domain/usecases/get_areas_usecase.dart';
import '../features/discover/domain/usecases/get_ooh_units_usecase.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton(() => Logger());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Auth Feature
  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceMock(),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () =>
        AuthRepositoryImpl(remoteDataSource: getIt(), localDataSource: getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton(() => LoginUseCase(getIt()));
  getIt.registerLazySingleton(() => RegisterUseCase(getIt()));
  getIt.registerLazySingleton(() => GetCurrentUserUseCase(getIt()));
  getIt.registerLazySingleton(() => LogoutUseCase(getIt()));

  // Discover Feature
  // Data Sources
  getIt.registerLazySingleton<OohRemoteDataSource>(
    () => OohRemoteDataSourceMock(),
  );
  // Repository
  getIt.registerLazySingleton<OohRepository>(
    () => OohRepositoryImpl(remoteDataSource: getIt()),
  );
  // Use Cases
  getIt.registerLazySingleton(() => GetOohUnitsUseCase(getIt()));
  getIt.registerLazySingleton(() => GetAreasUseCase(getIt()));
}
