import '../api/campaign_api_service.dart';
import '../dto/campaign_dto.dart';

class CampaignRepository {
  final CampaignApiService _apiService;

  CampaignRepository(this._apiService);

  Future<List<CampaignDto>> getCampaigns() async {
    return _apiService.getCampaigns();
  }

  Future<CampaignDto> createCampaign(Map<String, dynamic> data) async {
    return _apiService.createCampaign(data);
  }
}
