import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../discover/data/dto/dto.dart';

class AgencyApiService {
  final ApiClient _apiClient;

  AgencyApiService(this._apiClient);

  Future<List<DictionaryRefDto>> getBrands() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.agencyBrands);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createBrand(String name) async {
    await _apiClient.post(ApiConfig.agencyBrands, data: {'name': name});
  }
}
