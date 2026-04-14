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

  Future<void> updateItem(String type, int id, String name, {int? countryId}) async {
    switch (type) {
      case 'countries':
        await _apiService.updateCountry(id, name);
      case 'cities':
        await _apiService.updateCity(id, name, countryId!);
      case 'unitTypes':
        await _apiService.updateUnitType(id, name);
      case 'mediaFormats':
        await _apiService.updateMediaFormat(id, name);
      case 'venueTypes':
        await _apiService.updateVenueType(id, name);
    }
  }

  Future<void> deleteItem(String type, int id) async {
    switch (type) {
      case 'countries':
        await _apiService.deleteCountry(id);
      case 'cities':
        await _apiService.deleteCity(id);
      case 'unitTypes':
        await _apiService.deleteUnitType(id);
      case 'mediaFormats':
        await _apiService.deleteMediaFormat(id);
      case 'venueTypes':
        await _apiService.deleteVenueType(id);
    }
  }
}
