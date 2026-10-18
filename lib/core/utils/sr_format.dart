import 'package:intl/intl.dart';

/// Formatiranje za srpski prikaz: iznosi sa valutom, datumi, periodi i ciklusi zakupa.
///
/// Iznos uvek nosi valutu ("1.852,00 €", "12.000 RSD", "390 KM"), jer platforma
/// radi sa vlasnicima iz tri države i tri valute.
class SrFormat {
  SrFormat._();

  static final NumberFormat _decimal2 = NumberFormat('#,##0.00', 'en_US');
  static final NumberFormat _decimal0 = NumberFormat('#,##0', 'en_US');

  /// Simbol ili oznaka valute kako se piše posle iznosa.
  static String currencyLabel(String? currency) {
    switch ((currency ?? '').toUpperCase()) {
      case 'EUR':
        return '€';
      case 'BAM':
        return 'KM';
      case 'USD':
        return r'$';
      case 'GBP':
        return '£';
      case '':
        return '';
      default:
        return currency!.toUpperCase();
    }
  }

  static String _grouped(num value, {required bool decimals}) {
    final s = (decimals ? _decimal2 : _decimal0).format(value);
    // en_US: 1,234.50 -> sr: 1.234,50
    return s
        .replaceAll(',', '\u0001')
        .replaceAll('.', ',')
        .replaceAll('\u0001', '.');
  }

  /// "1.852,00 €"; [decimals] null = decimale samo kada iznos nije ceo.
  static String money(num? amount, String? currency, {bool? decimals}) {
    if (amount == null) return '—';
    final useDecimals =
        decimals ?? (amount.roundToDouble() != amount.toDouble());
    final label = currencyLabel(currency);
    final number = _grouped(amount, decimals: useDecimals);
    return label.isEmpty ? number : '$number $label';
  }

  /// "160 € / 4 nedelje"
  static String priceWithCycle(
      num? amount, String? currency, String? cycleType) {
    final cycle = cycleLabel(cycleType);
    final price = money(amount, currency, decimals: false);
    return cycle.isEmpty ? price : '$price / $cycle';
  }

  /// Normalizuje sve oblike ciklusa iz API-ja: "4-week", "FOUR_WEEK", "four_week", "fourWeek".
  static String _cycleKey(String? raw) {
    final v = (raw ?? '')
        .toLowerCase()
        .replaceAll('_', '')
        .replaceAll('-', '')
        .replaceAll(' ', '');
    const keys = {
      '1day': 'day',
      'oneday': 'day',
      'day': 'day',
      'daily': 'day',
      '1week': 'week',
      'oneweek': 'week',
      'week': 'week',
      'weekly': 'week',
      '2week': '2week',
      'twoweek': '2week',
      '2weeks': '2week',
      '4week': '4week',
      'fourweek': '4week',
      '4weeks': '4week',
      '1month': 'month',
      'onemonth': 'month',
      'month': 'month',
      'monthly': 'month',
    };
    return keys[v] ?? v;
  }

  /// Jedan ciklus: "dan", "nedelja", "2 nedelje", "4 nedelje", "mesec".
  static String cycleLabel(String? cycleType) {
    switch (_cycleKey(cycleType)) {
      case 'day':
        return 'dan';
      case 'week':
        return 'nedelja';
      case '2week':
        return '2 nedelje';
      case '4week':
        return '4 nedelje';
      case 'month':
        return 'mesec';
      case '':
        return '';
      default:
        return cycleType ?? '';
    }
  }

  /// Ciklus u trajanju za prikaz zakupa: "2 × 2 nedelje", "14 dana", "3 meseca".
  static String cyclesLabel(int? cycles, String? cycleType) {
    final key = _cycleKey(cycleType);
    if (cycles == null || cycles <= 0) return cycleLabel(cycleType);
    switch (key) {
      case 'day':
        return '$cycles ${_plural(cycles, 'dan', 'dana', 'dana')}';
      case 'week':
        return '$cycles ${_plural(cycles, 'nedelja', 'nedelje', 'nedelja')}';
      case 'month':
        return '$cycles ${_plural(cycles, 'mesec', 'meseca', 'meseci')}';
      default:
        return cycles == 1
            ? cycleLabel(cycleType)
            : '$cycles × ${cycleLabel(cycleType)}';
    }
  }

  /// Srpska množina: 1 dan, 2 dana, 5 dana; 21 dan; 22 dana.
  static String _plural(int n, String one, String few, String many) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return one;
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return few;
    return many;
  }

  static String plural(int n, String one, String few, String many) =>
      _plural(n, one, few, many);

  /// "3 površine", "5 površina", "1 površina"
  static String count(int n, String one, String few, String many) =>
      '$n ${_plural(n, one, few, many)}';

  static DateTime? parseDate(String? iso) {
    if (iso == null || iso.isEmpty) return null;
    return DateTime.tryParse(iso);
  }

  /// "16.11.2026."
  static String date(Object? value) {
    final d = value is DateTime ? value : parseDate(value?.toString());
    if (d == null) return '—';
    return '${d.day}.${d.month}.${d.year}.';
  }

  /// "16. nov 2026."
  static String dateShort(Object? value) {
    final d = value is DateTime ? value : parseDate(value?.toString());
    if (d == null) return '—';
    const months = [
      'jan',
      'feb',
      'mar',
      'apr',
      'maj',
      'jun',
      'jul',
      'avg',
      'sep',
      'okt',
      'nov',
      'dec'
    ];
    return '${d.day}. ${months[d.month - 1]} ${d.year}.';
  }

  /// "16.11. – 29.11.2026." (godina jednom kada je ista)
  static String period(String? start, String? end) {
    final s = parseDate(start);
    final e = parseDate(end);
    if (s == null && e == null) return '—';
    if (s == null) return 'do ${date(e)}';
    if (e == null) return 'od ${date(s)}';
    if (s.year == e.year) return '${s.day}.${s.month}. – ${date(e)}';
    return '${date(s)} – ${date(e)}';
  }

  /// Broj dana zakupa, uključujući oba datuma (kao na serveru).
  static int? days(String? start, String? end) {
    final s = parseDate(start);
    final e = parseDate(end);
    if (s == null || e == null) return null;
    return e.difference(s).inDays + 1;
  }

  static String daysLabel(int? days) =>
      days == null ? '' : '$days ${_plural(days, 'dan', 'dana', 'dana')}';

  /// "pre 3 dana", "danas", "juče"
  static String relative(Object? value) {
    final d = value is DateTime ? value : parseDate(value?.toString());
    if (d == null) return '';
    final now = DateTime.now();
    final diff = DateTime(now.year, now.month, now.day)
        .difference(DateTime(d.year, d.month, d.day))
        .inDays;
    if (diff <= 0) return 'danas';
    if (diff == 1) return 'juče';
    if (diff < 30) return 'pre $diff ${_plural(diff, 'dan', 'dana', 'dana')}';
    return date(d);
  }

  /// Zbir po valutama: {"EUR": 1852.0, "RSD": 12000.0} -> ["1.852 €", "12.000 RSD"]
  static List<String> totals(Map<String, double> byCurrency,
          {bool? decimals}) =>
      byCurrency.entries
          .map((e) => money(e.value, e.key, decimals: decimals))
          .toList();
}
