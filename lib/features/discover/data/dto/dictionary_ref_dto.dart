/// Reference DTO for dictionary items (city, country, unitType, etc.)
/// Matches backend DictionaryRefDto
class DictionaryRefDto {
  final int id;
  final String name;

  const DictionaryRefDto({
    required this.id,
    required this.name,
  });

  factory DictionaryRefDto.fromJson(Map<String, dynamic> json) {
    return DictionaryRefDto(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
