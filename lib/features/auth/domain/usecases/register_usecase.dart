import '../../../../core/utils/result.dart';
import '../entities/user.dart';
import '../entities/role.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<Result<User>> call(
    String name,
    String email,
    String password,
    Role role,
  ) {
    return repository.register(name, email, password, role);
  }
}
