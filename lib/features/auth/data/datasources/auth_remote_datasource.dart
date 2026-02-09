import '../../domain/entities/role.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String username, String password);
  Future<User> register(String name, String email, String password, Role role);
}
