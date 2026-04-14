import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';

class ProfileApiService {
  final ApiClient _apiClient;

  ProfileApiService(this._apiClient);

  Future<Map<String, dynamic>> getProfile() async {
    final response = await _apiClient.get<Map<String, dynamic>>(ApiConfig.profile);
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      ApiConfig.profile,
      data: data,
    );
    return response.data ?? {};
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      ApiConfig.profileChangePassword,
      data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }
}
