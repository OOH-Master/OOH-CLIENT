import '../../../../core/utils/result.dart';
import '../entities/ooh_unit.dart';
import '../entities/ooh_filters.dart';
import '../repositories/ooh_repository.dart';

class GetOohUnitsUseCase {
  final OohRepository repository;

  GetOohUnitsUseCase(this.repository);

  Future<Result<List<OohUnit>>> call({OohFilters? filters}) {
    return repository.getOohUnits(filters: filters);
  }
}
