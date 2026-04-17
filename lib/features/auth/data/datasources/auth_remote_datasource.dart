import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String username, String password);
  Future<User> register(
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
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> logout();
}
