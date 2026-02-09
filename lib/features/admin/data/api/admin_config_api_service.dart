import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../../../discover/data/dto/dto.dart';

class AdminConfigApiService {
  final ApiClient _apiClient;

  AdminConfigApiService(this._apiClient);

  Future<List<DictionaryRefDto>> getCountries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.adminConfigCountries);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCountry(String name) async {
    await _apiClient.post(ApiConfig.adminConfigCountries, data: {'name': name});
  }

  Future<List<DictionaryRefDto>> getCities() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.adminConfigCities);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createCity(String name, int countryId) async {
    await _apiClient.post(
      ApiConfig.adminConfigCities,
      data: {'name': name, 'countryId': countryId},
    );
  }

  Future<List<DictionaryRefDto>> getUnitTypes() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.adminConfigUnitTypes);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createUnitType(String name) async {
    await _apiClient.post(ApiConfig.adminConfigUnitTypes, data: {'name': name});
  }

  Future<List<DictionaryRefDto>> getMediaFormats() async {
    final response =
        await _apiClient.get<List<dynamic>>(ApiConfig.adminConfigMediaFormats);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createMediaFormat(String name) async {
    await _apiClient.post(ApiConfig.adminConfigMediaFormats, data: {'name': name});
  }

  Future<List<DictionaryRefDto>> getVenueTypes() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.adminConfigVenueTypes);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> createVenueType(String name) async {
    await _apiClient.post(ApiConfig.adminConfigVenueTypes, data: {'name': name});
  }
}
