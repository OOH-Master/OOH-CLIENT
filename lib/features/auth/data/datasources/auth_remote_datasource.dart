import '../../domain/entities/user.dart';
import '../../domain/entities/role.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password, Role role);
}

class AuthRemoteDataSourceMock implements AuthRemoteDataSource {
  @override
  Future<User> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    // Mock logic
    final role = email.toLowerCase().contains('brand')
        ? Role.brand
        : Role.agency;

    return User(id: 'mock-id-123', email: email, name: 'Mock User', role: role);
  }

  @override
  Future<User> register(
    String name,
    String email,
    String password,
    Role role,
  ) async {
    await Future.delayed(const Duration(seconds: 1));

    return User(id: 'mock-id-456', email: email, name: name, role: role);
  }
}
