import 'package:dio/dio.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_remote_datasource_impl.dart';
import '../datasources/auth_token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final AuthTokenStorage tokenStorage;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.tokenStorage,
    required this.apiClient,
  });

  @override
  Future<Result<User>> login(String username, String password) async {
    try {
      final user = await remoteDataSource.login(username, password);
      await localDataSource.cacheUser(user);
      return Success(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Error(AuthFailure('Pogrešno korisničko ime ili lozinka.'));
      }
      return Error(AuthFailure('Greška pri povezivanju. Pokušajte ponovo.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> register(
    String name,
    String email,
    String password,
    Role role,
  ) async {
    try {
      final user = await remoteDataSource.register(name, email, password, role);
      await localDataSource.cacheUser(user);
      return Success(user);
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        return Error(AuthFailure('Korisnik sa tim imenom već postoji.'));
      }
      return Error(AuthFailure('Greška pri povezivanju. Pokušajte ponovo.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final token = await tokenStorage.getToken();
      if (token == null) {
        return const Success(null);
      }

      // Set token on ApiClient and validate via /auth/me
      apiClient.setAuthToken(token);

      try {
        final response = await apiClient.get<Map<String, dynamic>>(ApiConfig.authMe);
        final data = response.data!;
        final user = User(
          id: data['id'].toString(),
          email: data['email'] ?? '',
          name: data['username'] ?? '',
          role: AuthRemoteDataSourceImpl.mapRole(data['role'] as String),
          companyName: data['companyName'] as String?,
          contactPerson: data['contactPerson'] as String?,
        );
        await localDataSource.cacheUser(user);
        return Success(user);
      } catch (_) {
        // Token invalid/expired - clear everything
        await tokenStorage.deleteToken();
        await localDataSource.clearUser();
        apiClient.clearAuthToken();
        return const Success(null);
      }
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await tokenStorage.deleteToken();
      await localDataSource.clearUser();
      apiClient.clearAuthToken();
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}
