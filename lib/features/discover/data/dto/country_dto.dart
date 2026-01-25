/// Country DTO matching backend CountryDto
class CountryDto {
  final int id;
  final String name;
  final String? code;

  const CountryDto({
    required this.id,
    required this.name,
    this.code,
  });

  factory CountryDto.fromJson(Map<String, dynamic> json) {
    return CountryDto(
      id: json['id'] as int,
      name: json['name'] as String,
      code: json['code'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}
