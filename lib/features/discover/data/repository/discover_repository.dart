import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/country.dart';
import '../../domain/entities/ooh_unit.dart';
import '../api/api.dart';
import '../dto/dto.dart';
import '../mapper/discover_mapper.dart';

/// Repository interface for discover feature
abstract class DiscoverRepository {
  Future<Result<List<Country>>> getCountries();
  Future<Result<List<City>>> getCities({int? countryId});
  Future<Result<List<OohUnit>>> getUnits({InventoryFilterParams? filters});
  Future<Result<OohUnit>> getUnitById(int id);

  Future<Result<List<DictionaryRefDto>>> getUnitTypes();

  Future<Result<List<DictionaryRefDto>>> getMediaFormats();

  Future<Result<List<DictionaryRefDto>>> getVenueTypes();
}

/// Implementation of DiscoverRepository using real API
class DiscoverRepositoryImpl implements DiscoverRepository {
  final ConfigApiService _configApi;
  final InventoryApiService _inventoryApi;

  DiscoverRepositoryImpl({
    required ConfigApiService configApi,
    required InventoryApiService inventoryApi,
  })  : _configApi = configApi,
        _inventoryApi = inventoryApi;

  @override
  Future<Result<List<Country>>> getCountries() async {
    try {
      final dtos = await _configApi.getCountries();
      final countries = DiscoverMapper.countriesFromDtoList(dtos);
      return Success(countries);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<City>>> getCities({int? countryId}) async {
    try {
      final dtos = await _configApi.getCities(countryId: countryId);
      final cities = dtos.map((dto) => DiscoverMapper.cityFromDto(dto)).toList();
      return Success(cities);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<OohUnit>>> getUnits({InventoryFilterParams? filters}) async {
    try {
      final dtos = await _inventoryApi.getUnits(filters: filters);
      final units = DiscoverMapper.unitsFromDtoList(dtos);
      return Success(units);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<OohUnit>> getUnitById(int id) async {
    try {
      final dto = await _inventoryApi.getUnitById(id);
      final unit = DiscoverMapper.unitFromDto(dto);
      return Success(unit);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<DictionaryRefDto>>> getUnitTypes() async {
    try {
      final dtos = await _configApi.getUnitTypes();
      return Success(dtos);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<DictionaryRefDto>>> getMediaFormats() async {
    try {
      final dtos = await _configApi.getMediaFormats();
      return Success(dtos);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<DictionaryRefDto>>> getVenueTypes() async {
    try {
      final dtos = await _configApi.getVenueTypes();
      return Success(dtos);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
