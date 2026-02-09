import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String username, String password);
  Future<Result<User>> register(
    String name,
    String email,
    String password,
    Role role,
  );
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> logout();
}
