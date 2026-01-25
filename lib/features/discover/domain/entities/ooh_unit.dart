import 'package:equatable/equatable.dart';

enum OohType { billboard, citylight, led, other }

class OohUnit extends Equatable {
  final String id;
  final String name;
  final OohType type;
  final String address;
  final String areaId;
  final double price;
  final String imageUrl;
  final bool isAvailable;
  final DateTime availableFrom;

  const OohUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.areaId,
    required this.price,
    required this.imageUrl,
    required this.isAvailable,
    required this.availableFrom,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    type,
    address,
    areaId,
    price,
    imageUrl,
    isAvailable,
    availableFrom,
  ];
}
