import '../../../../core/utils/result.dart';
import '../entities/role.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Result<User>> login(String username, String password);
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
  });
  Future<Result<User?>> getCurrentUser();
  Future<Result<void>> logout();
  Future<Result<void>> forgotPassword(String email);
  Future<Result<void>> resetPassword(String token, String newPassword);
}
