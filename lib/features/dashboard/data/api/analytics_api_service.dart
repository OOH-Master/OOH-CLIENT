import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../models/dashboard_models.dart';

/// Podaci kontrolnih tabli: analitika po ulozi i nekoliko lista koje tabla
/// prikazuje (zahtevi za ponude vlasnika medija, ponude klijenta).
class AnalyticsApiService {
  final ApiClient _apiClient;

  AnalyticsApiService(this._apiClient);

  Future<Map<String, dynamic>> getAdminOverview() async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConfig.adminAnalytics}/overview',
    );
    return JsonRead.map(response.data);
  }

  Future<Map<String, dynamic>> getAdminInquiryAnalytics() async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConfig.adminAnalytics}/inquiries',
    );
    return JsonRead.map(response.data);
  }

  /// Broj površina po tipu i po gradu (`countByType`, `countByCity`, `totalInventory`).
  Future<Map<String, dynamic>> getAdminInventoryAnalytics() async {
    final response = await _apiClient.get<dynamic>(
      '${ApiConfig.adminAnalytics}/inventory',
    );
    return JsonRead.map(response.data);
  }

  Future<Map<String, dynamic>> getMediaOwnerAnalytics() async {
    final response = await _apiClient.get<dynamic>(
      ApiConfig.mediaOwnerAnalytics,
    );
    return JsonRead.map(response.data);
  }

  Future<Map<String, dynamic>> getBrandAnalytics() async {
    final response = await _apiClient.get<dynamic>(
      ApiConfig.brandAnalytics,
    );
    return JsonRead.map(response.data);
  }

  Future<Map<String, dynamic>> getAgencyAnalytics() async {
    final response = await _apiClient.get<dynamic>(
      ApiConfig.agencyAnalytics,
    );
    return JsonRead.map(response.data);
  }

  /// Zahtevi za ponude vlasnika medija, isti endpoint kao stranica
  /// "Zahtevi za ponude"; prihvata i listu i Spring `Page`.
  Future<List<Map<String, dynamic>>> getMediaOwnerQuotes() async {
    final response = await _apiClient.get<dynamic>(ApiConfig.mediaOwnerQuotes);
    return JsonRead.list(response.data);
  }

  /// Objedinjena ponuda za upit brenda ili agencije.
  Future<Map<String, dynamic>> getClientOffer(
      {required bool agency, required int inquiryId}) async {
    final base = agency ? ApiConfig.agencyInquiries : ApiConfig.brandInquiries;
    final response = await _apiClient.get<dynamic>('$base/$inquiryId/offer');
    return JsonRead.map(response.data);
  }
}
