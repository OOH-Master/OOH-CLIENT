import '../../../../core/utils/failures.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/city.dart';
import '../../domain/entities/ooh_unit.dart';
import '../api/api.dart';
import '../mapper/discover_mapper.dart';

/// Repository interface for discover feature
abstract class DiscoverRepository {
  Future<Result<List<City>>> getCities({int? countryId});
  Future<Result<List<OohUnit>>> getUnits({InventoryFilterParams? filters});
  Future<Result<OohUnit>> getUnitById(int id);
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
  Future<Result<List<City>>> getCities({int? countryId}) async {
    try {
      final dtos = await _configApi.getCities(countryId: countryId);
      
      // Get inventory count for each city
      final cities = <City>[];
      for (final dto in dtos) {
        // Fetch units for this city to get count
        // Note: This is not optimal - backend should return inventory count directly
        // For now, we'll just map without count
        cities.add(DiscoverMapper.cityFromDto(dto));
      }
      
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
}
