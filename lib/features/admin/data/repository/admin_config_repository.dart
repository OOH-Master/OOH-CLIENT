import '../../../discover/data/dto/dto.dart';
import '../api/admin_config_api_service.dart';

class AdminConfigRepository {
  final AdminConfigApiService _apiService;

  AdminConfigRepository(this._apiService);

  Future<List<DictionaryRefDto>> getItems(String type) async {
    switch (type) {
      case 'countries':
        return _apiService.getCountries();
      case 'cities':
        return _apiService.getCities();
      case 'unitTypes':
        return _apiService.getUnitTypes();
      case 'mediaFormats':
        return _apiService.getMediaFormats();
      case 'venueTypes':
        return _apiService.getVenueTypes();
      default:
        return [];
    }
  }

  Future<void> createItem(String type, String name, {int? countryId}) async {
    switch (type) {
      case 'countries':
        await _apiService.createCountry(name);
      case 'cities':
        await _apiService.createCity(name, countryId!);
      case 'unitTypes':
        await _apiService.createUnitType(name);
      case 'mediaFormats':
        await _apiService.createMediaFormat(name);
      case 'venueTypes':
        await _apiService.createVenueType(name);
    }
  }
}
