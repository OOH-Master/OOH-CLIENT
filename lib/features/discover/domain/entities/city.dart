class City {
  final int id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final int inventoryCount;

  City({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.inventoryCount,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'] as int,
      name: json['name'] as String,
      country: json['country'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      inventoryCount: json['inventoryCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'inventoryCount': inventoryCount,
    };
  }
}
