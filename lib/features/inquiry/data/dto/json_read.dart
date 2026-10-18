/// Tolerantno čitanje vrednosti iz JSON odgovora: polja koja backend tek uvodi
/// mogu da izostanu, a iznosi (BigDecimal) stižu kao int, double ili tekst.
class JsonRead {
  JsonRead._();

  static int? integer(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  /// Tekst bez praznih vrednosti: "" i "   " postaju null.
  static String? text(Object? value) {
    if (value == null || value is Map || value is List) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }

  static bool? flag(Object? value) {
    if (value is bool) return value;
    if (value is String) return value.toLowerCase() == 'true';
    return null;
  }

  static Map<String, dynamic>? object(Object? value) =>
      value is Map ? Map<String, dynamic>.from(value) : null;

  static List<Map<String, dynamic>> objects(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Naziv iz rečničke reference `{id, name}`, ili sam tekst.
  static String? refName(Object? value) {
    if (value is Map) return text(value['name']);
    return text(value);
  }

  /// Iznosi po valuti: {"EUR": 1852.0, "RSD": 12000} (ključ velikim slovima).
  static Map<String, double> totals(Object? value) {
    if (value is! Map) return const <String, double>{};
    final result = <String, double>{};
    value.forEach((key, amount) {
      final n = number(amount);
      if (n != null) result[key.toString().trim().toUpperCase()] = n;
    });
    return result;
  }
}
