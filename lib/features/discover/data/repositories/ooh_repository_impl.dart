import '../../../../core/utils/result.dart';
import '../../../../core/utils/failures.dart';
import '../../domain/entities/ooh_unit.dart';
import '../../domain/entities/location_area.dart';
import '../../domain/entities/ooh_filters.dart';
import '../../domain/repositories/ooh_repository.dart';
import '../datasources/ooh_remote_datasource.dart';

class OohRepositoryImpl implements OohRepository {
  final OohRemoteDataSource remoteDataSource;

  OohRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Result<List<OohUnit>>> getOohUnits({OohFilters? filters}) async {
    try {
      final units = await remoteDataSource.getOohUnits(filters);
      return Success(units);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<LocationArea>>> getAreas() async {
    try {
      final areas = await remoteDataSource.getAreas();
      return Success(areas);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
