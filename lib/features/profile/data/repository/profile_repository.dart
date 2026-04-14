import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../api/profile_api_service.dart';

class ProfileRepository {
  final ProfileApiService _apiService;

  ProfileRepository(this._apiService);

  Future<Result<Map<String, dynamic>>> getProfile() async {
    try {
      final data = await _apiService.getProfile();
      return Success(data);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<Map<String, dynamic>>> updateProfile(Map<String, dynamic> data) async {
    try {
      final result = await _apiService.updateProfile(data);
      return Success(result);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return const Success(null);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
