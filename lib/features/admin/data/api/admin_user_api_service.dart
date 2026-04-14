import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';

class AdminUserApiService {
  final ApiClient _apiClient;

  AdminUserApiService(this._apiClient);

  Future<List<Map<String, dynamic>>> getUsers({
    String? role,
    bool? enabled,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (role != null) queryParams['role'] = role;
    if (enabled != null) queryParams['enabled'] = enabled.toString();
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.adminUsers,
      queryParameters: queryParams,
    );
    return (response.data ?? [])
        .map((json) => json as Map<String, dynamic>)
        .toList();
  }

  Future<Map<String, dynamic>> getUser(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.adminUsers}/$id',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.adminUsers}/$id',
      data: data,
    );
    return response.data ?? {};
  }

  Future<void> disableUser(int id) async {
    await _apiClient.post('${ApiConfig.adminUsers}/$id/disable');
  }

  Future<void> enableUser(int id) async {
    await _apiClient.post('${ApiConfig.adminUsers}/$id/enable');
  }
}
