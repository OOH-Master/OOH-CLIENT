import '../../../discover/data/dto/dto.dart';
import '../api/agency_api_service.dart';

class AgencyRepository {
  final AgencyApiService _apiService;

  AgencyRepository(this._apiService);

  Future<List<DictionaryRefDto>> getBrands() async {
    return _apiService.getBrands();
  }

  Future<void> createBrand(String name) async {
    return _apiService.createBrand(name);
  }
}
