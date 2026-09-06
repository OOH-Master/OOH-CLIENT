import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/config/api_client.dart';
import '../core/services/analytics_service.dart';
import '../features/admin/data/api/admin_config_api_service.dart';
import '../features/admin/data/api/admin_user_api_service.dart';
import '../features/admin/data/repository/admin_config_repository.dart';
import '../features/admin/data/repository/admin_user_repository.dart';
import '../features/agency/data/api/agency_api_service.dart';
import '../features/agency/data/repository/agency_repository.dart';
import '../features/auth/data/datasources/auth_local_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/datasources/auth_remote_datasource_impl.dart';
import '../features/auth/data/datasources/auth_token_storage.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/register_usecase.dart';
import '../features/availability/data/api/availability_api_service.dart';
import '../features/availability/data/repository/availability_repository.dart';
import '../features/campaign/data/api/campaign_api_service.dart';
import '../features/campaign/data/repository/campaign_repository.dart';
import '../features/dashboard/data/api/analytics_api_service.dart';
import '../features/dashboard/data/repository/analytics_repository.dart';
import '../features/discover/data/api/api.dart';
import '../features/discover/data/repository/discover_repository.dart';
import '../features/favorite/data/api/favorite_api_service.dart';
import '../features/favorite/data/repository/favorite_repository.dart';
import '../features/inquiry/data/api/inquiry_api_service.dart';
import '../features/inquiry/data/repository/inquiry_repository.dart';
import '../features/inventory_management/data/api/inventory_management_api_service.dart';
import '../features/inventory_management/data/repository/inventory_management_repository.dart';
import '../features/notification/data/api/notification_api_service.dart';
import '../features/notification/data/repository/notification_repository.dart';
import '../features/profile/data/api/profile_api_service.dart';
import '../features/profile/data/repository/profile_repository.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  getIt.registerLazySingleton(() => Logger());
  getIt.registerLazySingleton<AnalyticsService>(
      () => LogAnalyticsService(getIt<Logger>()));
  Analytics.use(getIt<AnalyticsService>());
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerSingleton<SharedPreferences>(sharedPreferences);

  // Auth Feature
  // Token Storage (registered before ApiClient so it can be injected)
  getIt.registerLazySingleton(() => AuthTokenStorage());

  // API Client with token storage for refresh interceptor
  getIt.registerLazySingleton(() => ApiClient(tokenStorage: getIt<AuthTokenStorage>()));

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
      tokenStorage: getIt<AuthTokenStorage>(),
    ),
  );
  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(getIt()),
  );
  // Repository
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt(),
      localDataSource: getIt(),
      tokenStorage: getIt<AuthTokenStorage>(),
      apiClient: getIt<ApiClient>(),
    ),
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

  // Inquiry Feature
  getIt.registerLazySingleton(() => InquiryApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => InquiryRepository(getIt<InquiryApiService>()));

  // Inventory Management Feature
  getIt.registerLazySingleton(() => InventoryManagementApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => InventoryManagementRepository(getIt<InventoryManagementApiService>()));

  // Campaign Feature
  getIt.registerLazySingleton(() => CampaignApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => CampaignRepository(getIt<CampaignApiService>()));

  // Admin Config Feature
  getIt.registerLazySingleton(() => AdminConfigApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminConfigRepository(getIt<AdminConfigApiService>()));

  // Admin User Feature
  getIt.registerLazySingleton(() => AdminUserApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AdminUserRepository(getIt<AdminUserApiService>()));

  // Agency Feature
  getIt.registerLazySingleton(() => AgencyApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AgencyRepository(getIt<AgencyApiService>()));

  // Availability Feature
  getIt.registerLazySingleton(() => AvailabilityApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AvailabilityRepository(getIt<AvailabilityApiService>()));

  // Profile Feature
  getIt.registerLazySingleton(() => ProfileApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => ProfileRepository(getIt<ProfileApiService>()));

  // Analytics Feature
  getIt.registerLazySingleton(() => AnalyticsApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => AnalyticsRepository(getIt<AnalyticsApiService>()));

  // Notification Feature
  getIt.registerLazySingleton(() => NotificationApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => NotificationRepository(getIt<NotificationApiService>()));

  // Favorite Feature
  getIt.registerLazySingleton(() => FavoriteApiService(getIt<ApiClient>()));
  getIt.registerLazySingleton(() => FavoriteRepository(getIt<FavoriteApiService>()));
}
