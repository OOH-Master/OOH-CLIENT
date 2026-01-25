import '../../domain/entities/ooh_unit.dart';
import '../../domain/entities/location_area.dart';
import '../../domain/entities/ooh_filters.dart';

abstract class OohRemoteDataSource {
  Future<List<OohUnit>> getOohUnits(OohFilters? filters);
  Future<List<LocationArea>> getAreas();
}

class OohRemoteDataSourceMock implements OohRemoteDataSource {
  final List<LocationArea> _areas = const [
    LocationArea(id: 'bg-stari-grad', name: 'Stari Grad'),
    LocationArea(id: 'bg-novi-beograd', name: 'Novi Beograd'),
    LocationArea(id: 'bg-vracar', name: 'Vračar'),
    LocationArea(id: 'bg-savski-venac', name: 'Savski Venac'),
  ];

  final List<OohUnit> _allUnits = [
    OohUnit(
      id: '1',
      name: 'Brankov Most Billboard',
      type: OohType.billboard,
      address: 'Brankov Most, Beograd',
      areaId: 'bg-stari-grad',
      price: 1200.0,
      imageUrl: 'https://via.placeholder.com/400x300?text=Billboard+1',
      isAvailable: true,
      availableFrom: DateTime.now(),
    ),
    OohUnit(
      id: '2',
      name: 'Ušće Tower LED',
      type: OohType.led,
      address: 'Bulevar Mihajla Pupina 6',
      areaId: 'bg-novi-beograd',
      price: 3500.0,
      imageUrl: 'https://via.placeholder.com/400x300?text=LED+Screen',
      isAvailable: false,
      availableFrom: DateTime.now().add(const Duration(days: 30)),
    ),
    OohUnit(
      id: '3',
      name: 'Slavija Square Citylight',
      type: OohType.citylight,
      address: 'Trg Slavija',
      areaId: 'bg-vracar',
      price: 450.0,
      imageUrl: 'https://via.placeholder.com/400x300?text=Citylight',
      isAvailable: true,
      availableFrom: DateTime.now(),
    ),
    OohUnit(
      id: '4',
      name: 'Genex Tower Billboard',
      type: OohType.billboard,
      address: 'Narodnih Heroja',
      areaId: 'bg-novi-beograd',
      price: 900.0,
      imageUrl: 'https://via.placeholder.com/400x300?text=Genex',
      isAvailable: true,
      availableFrom: DateTime.now(),
    ),
    OohUnit(
      id: '5',
      name: 'Gazela Bridge Mega',
      type: OohType.billboard,
      address: 'Gazela Bridge',
      areaId: 'bg-savski-venac',
      price: 2200.0,
      imageUrl: 'https://via.placeholder.com/400x300?text=Mega+Board',
      isAvailable: true,
      availableFrom: DateTime.now(),
    ),
  ];

  @override
  Future<List<OohUnit>> getOohUnits(OohFilters? filters) async {
    await Future.delayed(const Duration(milliseconds: 800));

    var units = _allUnits;

    if (filters != null) {
      if (filters.type != null) {
        units = units.where((u) => u.type == filters.type).toList();
      }
      if (filters.areaId != null) {
        units = units.where((u) => u.areaId == filters.areaId).toList();
      }
      if (filters.minPrice != null) {
        units = units.where((u) => u.price >= filters.minPrice!).toList();
      }
      if (filters.maxPrice != null) {
        units = units.where((u) => u.price <= filters.maxPrice!).toList();
      }
    }

    return units;
  }

  @override
  Future<List<LocationArea>> getAreas() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _areas;
  }
}
