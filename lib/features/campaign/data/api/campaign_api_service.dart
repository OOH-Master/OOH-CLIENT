import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/campaign_dto.dart';

class CampaignApiService {
  final ApiClient _apiClient;

  CampaignApiService(this._apiClient);

  Future<List<CampaignDto>> getCampaigns() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.campaigns);
    return (response.data ?? [])
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
}
