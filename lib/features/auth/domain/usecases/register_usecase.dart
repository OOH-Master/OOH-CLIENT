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
    Role role, {
    String? firstName,
    String? lastName,
    String? companyName,
    String? phone,
    String? country,
    String? city,
  }) {
    return repository.register(
      name, email, password, role,
      firstName: firstName,
      lastName: lastName,
      companyName: companyName,
      phone: phone,
      country: country,
      city: city,
    );
  }
}
