import '../../../../core/utils/result.dart';
import '../entities/ooh_unit.dart';
import '../entities/location_area.dart';
import '../entities/ooh_filters.dart';

abstract class OohRepository {
  Future<Result<List<OohUnit>>> getOohUnits({OohFilters? filters});
  Future<Result<List<LocationArea>>> getAreas();
}
