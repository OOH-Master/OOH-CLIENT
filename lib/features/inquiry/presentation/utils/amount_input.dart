/// Unos iznosa u polju za cenu: korisnik piše "180", "180,50" ili "1.200".
class AmountInput {
  AmountInput._();

  /// Tekst za polje: ceo iznos bez decimala ("180"), ostali sa zarezom ("180,50").
  static String format(double? amount) {
    if (amount == null) return '';
    if (amount == amount.roundToDouble()) return amount.toInt().toString();
    return amount.toStringAsFixed(2).replaceAll('.', ',');
  }

  /// Iznos iz teksta; prihvata zarez ili tačku kao decimalni znak i tačku ili
  /// razmak kao separator hiljada. Vraća null za prazan ili neispravan unos.
  static double? parse(String raw) {
    var s = raw.replaceAll(
        RegExp(r'[\s€]|RSD|KM|BAM|EUR', caseSensitive: false), '');
    if (s.isEmpty) return null;
    final hasComma = s.contains(',');
    final hasDot = s.contains('.');
    if (hasComma && hasDot) {
      // "1.200,50": tačka razdvaja hiljade, zarez decimale
      s = s.replaceAll('.', '').replaceAll(',', '.');
    } else if (hasComma) {
      s = s.replaceAll(',', '.');
    } else if (hasDot && RegExp(r'^\d{1,3}(\.\d{3})+$').hasMatch(s)) {
      // "1.200" je hiljadu dvesta, ne 1,2
      s = s.replaceAll('.', '');
    }
    final value = double.tryParse(s);
    if (value == null || value.isNaN || value.isInfinite) return null;
    return value;
  }
}
