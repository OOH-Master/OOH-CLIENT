import '../../../../core/utils/result.dart';
import '../entities/location_area.dart';
import '../repositories/ooh_repository.dart';

class GetAreasUseCase {
  final OohRepository repository;

  GetAreasUseCase(this.repository);

  Future<Result<List<LocationArea>>> call() {
    return repository.getAreas();
  }
}
