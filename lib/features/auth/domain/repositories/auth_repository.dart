import '../entities/user.dart';
import '../entities/role.dart';
import '../../../../core/utils/result.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String email, String password);
  Future<Result<User>> register(
    String name,
    String email,
    String password,
    Role role,
  );
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> logout();
}
