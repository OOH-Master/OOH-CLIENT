import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/dto.dart';

/// API service for public config endpoints (cities, countries, unit types, etc.)
class ConfigApiService {
  final ApiClient _apiClient;

  ConfigApiService(this._apiClient);

  /// Get all countries
  Future<List<CountryDto>> getCountries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.publicCountries);
    return (response.data ?? [])
        .map((json) => CountryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all cities, optionally filtered by country
  Future<List<CityDto>> getCities({int? countryId}) async {
    final queryParams = <String, dynamic>{};
    if (countryId != null) {
      queryParams['countryId'] = countryId;
    }
    
    final response = await _apiClient.get<List<dynamic>>(
      ApiConfig.publicCities,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return (response.data ?? [])
        .map((json) => CityDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all unit types
  Future<List<DictionaryRefDto>> getUnitTypes() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.publicUnitTypes);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all media formats
  Future<List<DictionaryRefDto>> getMediaFormats() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.publicMediaFormats);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Get all venue types
  Future<List<DictionaryRefDto>> getVenueTypes() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.publicVenueTypes);
    return (response.data ?? [])
        .map((json) => DictionaryRefDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
