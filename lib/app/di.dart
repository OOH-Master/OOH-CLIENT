import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_client.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/discover/data/api/api.dart';
import '../features/discover/data/repository/discover_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton(() => Logger());
  getIt.registerLazySingleton(() => ApiClient());
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
  // API Services
  getIt.registerLazySingleton(() => ConfigApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => InventoryApiService(getIt<ApiClient>()));
  // Repository
  getIt.registerLazySingleton<DiscoverRepository>(
    () => DiscoverRepositoryImpl(
      configApi: getIt<ConfigApiService>(),
      inventoryApi: getIt<InventoryApiService>(),
    ),
  );
}
