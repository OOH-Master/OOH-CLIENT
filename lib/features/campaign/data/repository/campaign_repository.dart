import '../api/campaign_api_service.dart';
import '../dto/campaign_dto.dart';

class CampaignRepository {
  final CampaignApiService _apiService;

  CampaignRepository(this._apiService);

  Future<List<CampaignDto>> getCampaigns() async {
    return _apiService.getCampaigns();
  }

  Future<CampaignDto> getCampaignById(int id) async {
    return _apiService.getCampaignById(id);
  }

  Future<CampaignDto> createCampaign(Map<String, dynamic> data) async {
    return _apiService.createCampaign(data);
  }

  Future<CampaignDto> updateCampaign(int id, Map<String, dynamic> data) async {
    return _apiService.updateCampaign(id, data);
  }

  Future<void> deleteCampaign(int id) async {
    return _apiService.deleteCampaign(id);
  }

  Future<CampaignDto> changeStatus(int id, String status) async {
    return _apiService.changeStatus(id, status);
  }

  Future<CampaignDto> createFromInquiry(int inquiryId) async {
    return _apiService.createFromInquiry(inquiryId);
  }
}
