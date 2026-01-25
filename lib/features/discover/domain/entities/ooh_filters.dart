import 'package:equatable/equatable.dart';
import 'ooh_unit.dart';

class OohFilters extends Equatable {
  final OohType? type;
  final String? areaId;
  final double? minPrice;
  final double? maxPrice;

  const OohFilters({this.type, this.areaId, this.minPrice, this.maxPrice});

  @override
  List<Object?> get props => [type, areaId, minPrice, maxPrice];
}
