import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/campaign_dto.dart';

class CampaignApiService {
  final ApiClient _apiClient;

  CampaignApiService(this._apiClient);

  Future<List<CampaignDto>> getCampaigns() async {
    final response = await _apiClient.get<dynamic>(ApiConfig.campaigns);
    final data = response.data;
    List<dynamic> content;
    if (data is Map<String, dynamic> && data.containsKey('content')) {
      content = (data['content'] as List<dynamic>?) ?? [];
    } else if (data is List) {
      content = data;
    } else {
      content = [];
    }
    return content
        .map((json) => CampaignDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<CampaignDto> getCampaignById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.campaigns}/$id',
    );
    return CampaignDto.fromJson(response.data!);
  }

  Future<CampaignDto> createCampaign(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.campaigns,
      data: data,
    );
    return CampaignDto.fromJson(response.data!);
  }

  Future<CampaignDto> updateCampaign(int id, Map<String, dynamic> data) async {
    final response = await _apiClient.put<Map<String, dynamic>>(
      '${ApiConfig.campaigns}/$id',
      data: data,
    );
    return CampaignDto.fromJson(response.data!);
  }

  Future<void> deleteCampaign(int id) async {
    await _apiClient.delete('${ApiConfig.campaigns}/$id');
  }

  Future<CampaignDto> changeStatus(int id, String status) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.campaigns}/$id/status',
      data: {'status': status},
    );
    return CampaignDto.fromJson(response.data!);
  }

  Future<CampaignDto> createFromInquiry(int inquiryId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.campaigns}/from-inquiry/$inquiryId',
    );
    return CampaignDto.fromJson(response.data!);
  }
}
