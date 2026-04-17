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
      final message = _extractErrorMessage(e);
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        return Error(AuthFailure(message ?? 'Pogrešno korisničko ime ili lozinka.'));
      }
      if (e.response?.statusCode == 423) {
        return Error(AuthFailure(message ?? 'Nalog je zaključan. Pokušajte ponovo za 15 minuta.'));
      }
      return Error(AuthFailure(message ?? 'Greška pri povezivanju. Pokušajte ponovo.'));
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> register(
    String name,
    String email,
    String password,
    Role role, {
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
    String? country,
    String? city,
  }) async {
    try {
      final user = await remoteDataSource.register(
        name, email, password, role,
        firstName: firstName,
        lastName: lastName,
        companyName: companyName,
        phone: phone,
        country: country,
        city: city,
      );
      await localDataSource.cacheUser(user);
      return Success(user);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      if (e.response?.statusCode == 400) {
        return Error(AuthFailure(message ?? 'Neispravni podaci. Proverite unos.'));
      }
      return Error(AuthFailure(message ?? 'Greška pri povezivanju. Pokušajte ponovo.'));
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
          firstName: data['firstName'] as String?,
          lastName: data['lastName'] as String?,
          phone: data['phone'] as String?,
          country: data['country'] as String?,
          city: data['city'] as String?,
          website: data['website'] as String?,
          emailVerified: data['emailVerified'] as bool? ?? false,
        );
        await localDataSource.cacheUser(user);
        return Success(user);
      } catch (_) {
        // Token invalid/expired - clear everything
        await tokenStorage.clearAll();
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
      await remoteDataSource.logout();
      await tokenStorage.clearAll();
      await localDataSource.clearUser();
      apiClient.clearAuthToken();
      return const Success(null);
    } catch (e) {
      // Still clear local tokens even if remote logout fails
      await tokenStorage.clearAll();
      await localDataSource.clearUser();
      apiClient.clearAuthToken();
      return const Success(null);
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await remoteDataSource.forgotPassword(email);
      return const Success(null);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return Error(ServerFailure(message ?? 'Failed to send reset email.'));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    try {
      await remoteDataSource.resetPassword(token, newPassword);
      return const Success(null);
    } on DioException catch (e) {
      final message = _extractErrorMessage(e);
      return Error(ServerFailure(message ?? 'Failed to reset password.'));
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  String? _extractErrorMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
