import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../data/dto/dto.dart';
import '../../domain/entities/ooh_unit.dart';

/// Izvedeni podaci za prikaz jedne površine: naslov, mesto, oznake i cena.
/// Isto se računa za karticu, red liste, kartu na mapi i detalj površine.
extension OohUnitLabels on OohUnit {
  int? get intId => int.tryParse(id);

  bool get isDigitalUnit {
    final t = unitTypeName;
    if (t != null && t.isNotEmpty) return SrLabels.isDigital(t);
    return type == OohType.digital;
  }

  /// "Statična", "Digitalna"...
  String get typeLabel {
    final t = unitTypeName;
    if (t != null && t.isNotEmpty) return SrLabels.unitType(t);
    return type == OohType.digital ? 'Digitalna' : '';
  }

  String get formatLabel => SrLabels.format(mediaFormatName);

  String get vendorFormatLabel =>
      _capitalize(SrLabels.format(vendorFormatName));

  String get venueLabel => SrLabels.venue(venueTypeName);

  String get illuminationLabel => SrLabels.illumination(illumination);

  /// "12 × 4 m"
  String get dimensionsLabel =>
      SrLabels.dimensions(physicalWidth, physicalHeight, sizeUnit);

  /// "1080 × 1920 px"
  String get resolutionLabel {
    final w = pixelWidth ?? 0;
    final h = pixelHeight ?? 0;
    return w > 0 && h > 0 ? '$w × $h px' : '';
  }

  String get cityLabel => SrLabels.city(cityName);

  String get countryLabel => SrLabels.country(countryName);

  /// "Beograd, Srbija"
  String get cityAndCountry => SrLabels.place(cityName, countryName);

  bool get _hasSiteName =>
      name.isNotEmpty && name != code && !name.startsWith('Površina #');

  /// Naziv lokacije; kada ga uvoz nema, format vlasnika ("Megabord"), a šifra
  /// ostaje u posebnoj oznaci.
  String get title {
    if (_hasSiteName) return name;
    final f = vendorFormatLabel.isNotEmpty ? vendorFormatLabel : formatLabel;
    return f.isNotEmpty ? _capitalize(f) : name;
  }

  /// "Bana Milosavljevića bb, Banja Luka" ili "Beograd, Srbija"
  String get placeLine {
    final street = address.trim();
    final hasLetters = RegExp(r'[A-Za-zČĆŽŠĐčćžšđ]').hasMatch(street);
    if (street.isEmpty || !hasLetters) return cityAndCountry;
    final city = cityLabel;
    if (city.isEmpty || street.toLowerCase().contains(city.toLowerCase())) {
      return street;
    }
    return '$street, $city';
  }

  /// Najviše [max] oznaka: format, okruženje, dimenzije (ili rezolucija).
  List<String> specChips({int max = 3}) {
    final out = <String>[];
    void add(String v) {
      if (v.isEmpty || out.contains(v) || out.length >= max) return;
      out.add(v);
    }

    if (formatLabel != title) add(formatLabel);
    add(venueLabel);
    add(dimensionsLabel.isNotEmpty ? dimensionsLabel : resolutionLabel);
    add(illuminationLabel);
    return out;
  }

  /// "200 €" (bez ciklusa); bez cene "Cena na upit".
  String get priceAmount => hasPrice
      ? SrFormat.money(price, currency, decimals: false)
      : 'Cena na upit';

  /// "4 nedelje"
  String get cycleText => SrFormat.cycleLabel(cycleType.name);

  String get statusLabel {
    switch (status) {
      case OohStatus.available:
        return 'Dostupno';
      case OohStatus.booked:
        return 'Zauzeto';
      case OohStatus.maintenance:
        return 'Na održavanju';
    }
  }

  PillTone get statusTone {
    switch (status) {
      case OohStatus.available:
        return PillTone.success;
      case OohStatus.booked:
        return PillTone.danger;
      case OohStatus.maintenance:
        return PillTone.neutral;
    }
  }
}

String _capitalize(String s) =>
    s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

/// Opcija filtera iz rečnika: srpski naziv i id koji se šalje u filter.
class DictionaryOption {
  final int id;
  final String label;

  const DictionaryOption(this.id, this.label);
}

/// Srpski tekstovi pretrage: broj rezultata, izbor i oznake filtera.
class DiscoverLabels {
  DiscoverLabels._();

  /// "1 površina", "3 površine", "57 površina"
  static String unitCount(int n) =>
      SrFormat.count(n, 'površina', 'površine', 'površina');

  /// "3 izabrane površine"
  static String selectedCount(int n) => SrFormat.count(
      n, 'izabrana površina', 'izabrane površine', 'izabranih površina');

  static const Map<String, String> _locatives = {
    'Srbija': 'Srbiji',
    'Hrvatska': 'Hrvatskoj',
    'Bosna i Hercegovina': 'Bosni i Hercegovini',
    'Crna Gora': 'Crnoj Gori',
    'Slovenija': 'Sloveniji',
    'Severna Makedonija': 'Severnoj Makedoniji',
  };

  /// "u gradu Beograd", "u Srbiji", "u državi Crna Gora", "u svim državama"
  static String scope({String? city, String? country}) {
    final c = SrLabels.city(city);
    if (c.isNotEmpty) return 'u gradu $c';
    final k = SrLabels.country(country);
    final loc = _locatives[k];
    if (loc != null) return 'u $loc';
    if (k.isNotEmpty) return 'u državi $k';
    return 'u svim državama';
  }

  /// "57 površina u gradu Beograd"
  static String results(int n, {String? city, String? country}) =>
      '${unitCount(n)} ${scope(city: city, country: country)}';

  /// Okruženje (vrednost enuma koja ide u filter): "Unutra", "Spolja"...
  static String environment(String value) {
    switch (value.toUpperCase()) {
      case 'INDOOR':
        return 'Unutra';
      case 'OUTDOOR':
        return 'Spolja';
      case 'ROADSIDE':
        return 'Pored puta';
      case 'MALL':
        return 'Tržni centar';
      case 'AIRPORT':
        return 'Aerodrom';
      case 'TRANSIT':
        return 'Javni prevoz';
      case 'OTHER':
        return 'Ostalo';
      default:
        return SrLabels.venue(value);
    }
  }

  static String illumination(String value) {
    final l = SrLabels.illumination(value);
    return l.isEmpty ? value : l;
  }

  static String unitType(String name) => _orRaw(SrLabels.unitType(name), name);

  static String format(String name) => _orRaw(SrLabels.format(name), name);

  static String venue(String name) => _orRaw(SrLabels.venue(name), name);

  static String _orRaw(String label, String raw) => label.isEmpty ? raw : label;

  /// Rečnik sa srpskim nazivima. Uvoz ponekad ima dva zapisa istog značenja
  /// ("Mall" i "Malls"), pa se prikazuje jedna opcija: izabrana, pa ona koja
  /// ima površine u trenutnim rezultatima, inače prva.
  static List<DictionaryOption> options(
    List<DictionaryRefDto> items,
    String Function(String name) labelOf, {
    Set<String> present = const {},
    int? selectedId,
  }) {
    final chosen = <String, DictionaryRefDto>{};
    final order = <String>[];
    int score(DictionaryRefDto d) {
      if (d.id == selectedId) return 2;
      return present.contains(d.name.toLowerCase()) ? 1 : 0;
    }

    for (final item in items) {
      final label = labelOf(item.name);
      final current = chosen[label];
      if (current == null) {
        chosen[label] = item;
        order.add(label);
      } else if (score(item) > score(current)) {
        chosen[label] = item;
      }
    }
    return [for (final l in order) DictionaryOption(chosen[l]!.id, l)];
  }

  /// Naziv izabrane stavke rečnika za oznaku aktivnog filtera.
  static String? dictionaryLabel(List<DictionaryRefDto> items, int? id,
      String Function(String name) labelOf) {
    if (id == null) return null;
    for (final item in items) {
      if (item.id == id) return labelOf(item.name);
    }
    return null;
  }
}
