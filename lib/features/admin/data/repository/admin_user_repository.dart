import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../api/admin_user_api_service.dart';

class AdminUserRepository {
  final AdminUserApiService _apiService;

  AdminUserRepository(this._apiService);

  Future<Result<List<Map<String, dynamic>>>> getUsers({
    String? role,
    bool? enabled,
    String? search,
  }) async {
    try {
      final users = await _apiService.getUsers(
        role: role,
        enabled: enabled,
        search: search,
      );
      return Success(users);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> getUser(int id) async {
    try {
      final user = await _apiService.getUser(id);
      return Success(user);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> updateUser(int id, Map<String, dynamic> data) async {
    try {
      final user = await _apiService.updateUser(id, data);
      return Success(user);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> disableUser(int id) async {
    try {
      await _apiService.disableUser(id);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> enableUser(int id) async {
    try {
      await _apiService.enableUser(id);
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
