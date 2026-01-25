import '../../../../core/utils/result.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final user = await remoteDataSource.login(email, password);
      await localDataSource.cacheUser(user);
      return Success(user);
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
    } catch (e) {
      return Error(AuthFailure(e.toString()));
    }
  }

  @override
  Future<Result<User?>> getCurrentUser() async {
    try {
      final user = await localDataSource.getLastUser();
      return Success(user);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Success(null);
    } catch (e) {
      return Error(CacheFailure(e.toString()));
    }
  }
}
