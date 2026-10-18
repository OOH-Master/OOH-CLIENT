import '../../../../core/utils/sr_format.dart';

/// Zbir iznosa po valuti. Stavke jedne ponude mogu biti u EUR, RSD i BAM, pa se
/// iznosi nikad ne sabiraju u jedan broj.
class CurrencyTotals {
  CurrencyTotals._();

  /// Oznaka koju backend koristi kada stavka nema valutu.
  static const String unknown = 'N/A';

  /// Sabira iznose po valuti, preskačući stavke bez iznosa; redosled prati prvo
  /// pojavljivanje valute.
  static Map<String, double> sum<T>(
    Iterable<T> items,
    double? Function(T item) amount,
    String? Function(T item) currency,
  ) {
    final totals = <String, double>{};
    for (final item in items) {
      final value = amount(item);
      if (value == null) continue;
      final key = (currency(item) ?? '').trim().toUpperCase();
      totals[key] = (totals[key] ?? 0) + value;
    }
    return totals;
  }

  /// Valuta za prikaz: nepoznata valuta se prikazuje bez oznake.
  static String? displayCurrency(String key) =>
      key.isEmpty || key == unknown ? null : key;

  /// ["1.852 €", "12.000 RSD"]
  static List<String> labels(Map<String, double> totals) => totals.entries
      .map((e) => SrFormat.money(e.value, displayCurrency(e.key)))
      .toList();

  /// "1.852 €, 12.000 RSD"
  static String inline(Map<String, double> totals, {String empty = '—'}) {
    final parts = labels(totals);
    return parts.isEmpty ? empty : parts.join(', ');
  }
}
