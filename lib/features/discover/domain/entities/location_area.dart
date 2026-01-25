import 'package:equatable/equatable.dart';

class LocationArea extends Equatable {
  final String id;
  final String name;

  const LocationArea({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
