/// City DTO matching backend CityDto
class CityDto {
  final int id;
  final String name;
  final int? countryId;
  final String? countryName;
  final double? latitude;
  final double? longitude;

  const CityDto({
    required this.id,
    required this.name,
    this.countryId,
    this.countryName,
    this.latitude,
    this.longitude,
  });

  factory CityDto.fromJson(Map<String, dynamic> json) {
    return CityDto(
      id: json['id'] as int,
      name: json['name'] as String,
      countryId: json['countryId'] as int?,
      countryName: json['countryName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'countryId': countryId,
      'countryName': countryName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
