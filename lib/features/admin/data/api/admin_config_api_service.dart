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

  // Update methods
  Future<void> updateCountry(int id, String name) async {
    await _apiClient.put('${ApiConfig.adminConfigCountries}/$id', data: {'name': name});
  }

  Future<void> updateCity(int id, String name, int countryId) async {
    await _apiClient.put('${ApiConfig.adminConfigCities}/$id', data: {'name': name, 'countryId': countryId});
  }

  Future<void> updateUnitType(int id, String name) async {
    await _apiClient.put('${ApiConfig.adminConfigUnitTypes}/$id', data: {'name': name});
  }

  Future<void> updateMediaFormat(int id, String name) async {
    await _apiClient.put('${ApiConfig.adminConfigMediaFormats}/$id', data: {'name': name});
  }

  Future<void> updateVenueType(int id, String name) async {
    await _apiClient.put('${ApiConfig.adminConfigVenueTypes}/$id', data: {'name': name});
  }

  // Delete methods
  Future<void> deleteCountry(int id) async {
    await _apiClient.delete('${ApiConfig.adminConfigCountries}/$id');
  }

  Future<void> deleteCity(int id) async {
    await _apiClient.delete('${ApiConfig.adminConfigCities}/$id');
  }

  Future<void> deleteUnitType(int id) async {
    await _apiClient.delete('${ApiConfig.adminConfigUnitTypes}/$id');
  }

  Future<void> deleteMediaFormat(int id) async {
    await _apiClient.delete('${ApiConfig.adminConfigMediaFormats}/$id');
  }

  Future<void> deleteVenueType(int id) async {
    await _apiClient.delete('${ApiConfig.adminConfigVenueTypes}/$id');
  }
}
