import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';

class AnalyticsApiService {
  final ApiClient _apiClient;

  AnalyticsApiService(this._apiClient);

  Future<Map<String, dynamic>> getAdminOverview() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.adminAnalytics}/overview',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getAdminInquiryAnalytics() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.adminAnalytics}/inquiries',
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getMediaOwnerAnalytics() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.mediaOwnerAnalytics,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getBrandAnalytics() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.brandAnalytics,
    );
    return response.data ?? {};
  }

  Future<Map<String, dynamic>> getAgencyAnalytics() async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.agencyAnalytics,
    );
    return response.data ?? {};
  }
}
