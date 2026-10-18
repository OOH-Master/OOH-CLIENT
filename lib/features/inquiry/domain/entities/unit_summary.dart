import '../../../../core/utils/sr_labels.dart';
import '../../data/dto/json_read.dart';

/// Sažetak oglasne površine koji backend šalje uz stavku upita, ponude vlasnika
/// medija i objedinjene ponude (ključ `unit`). Sva polja su opciona: stariji
/// backend ih ne šalje, pa se sažetak tada gradi iz ravnih polja stavke
/// ([UnitSummary.basic]).
class UnitSummary {
  final int? id;
  final String? code;
  final String? siteName;
  final String? address;
  final String? city;
  final String? country;
  final String? itemType;
  final String? mediaFormat;
  final String? venueType;
  final String? unitType;
  final String? environment;
  final String? illumination;
  final double? physicalWidth;
  final double? physicalHeight;
  final String? sizeUnit;
  final int? pixelWidth;
  final int? pixelHeight;
  final String? imageUrl;
  final double? pricePerCycle;
  final String? currency;
  final String? cycleType;
  final String? mediaOwnerName;
  final double? lat;
  final double? lng;
  final int? impressions;

  /// Dostupnost iz javnog inventara (stavke upita je ne nose).
  final bool available;

  const UnitSummary({
    this.id,
    this.code,
    this.siteName,
    this.address,
    this.city,
    this.country,
    this.itemType,
    this.mediaFormat,
    this.venueType,
    this.unitType,
    this.environment,
    this.illumination,
    this.physicalWidth,
    this.physicalHeight,
    this.sizeUnit,
    this.pixelWidth,
    this.pixelHeight,
    this.imageUrl,
    this.pricePerCycle,
    this.currency,
    this.cycleType,
    this.mediaOwnerName,
    this.lat,
    this.lng,
    this.impressions,
    this.available = true,
  });

  /// `UnitSummaryDto` (ključ `unit` na stavkama).
  factory UnitSummary.fromJson(Map<String, dynamic> json) {
    return UnitSummary(
      id: JsonRead.integer(json['id']),
      code: JsonRead.text(json['code']),
      siteName: JsonRead.text(json['siteName']),
      address: JsonRead.text(json['address']),
      city: JsonRead.refName(json['city']),
      country: JsonRead.refName(json['country']),
      itemType: JsonRead.text(json['itemType']),
      mediaFormat: JsonRead.refName(json['mediaFormat']),
      venueType: JsonRead.refName(json['venueType']),
      unitType: JsonRead.refName(json['unitType']),
      environment: JsonRead.text(json['environment']),
      illumination: JsonRead.text(json['illumination']),
      physicalWidth: JsonRead.number(json['physicalWidth']),
      physicalHeight: JsonRead.number(json['physicalHeight']),
      sizeUnit: JsonRead.text(json['sizeUnit']),
      pixelWidth: JsonRead.integer(json['pixelWidth']),
      pixelHeight: JsonRead.integer(json['pixelHeight']),
      imageUrl: JsonRead.text(json['imageUrl']),
      pricePerCycle: JsonRead.number(json['pricePerCycle']),
      currency: JsonRead.text(json['currency']),
      cycleType: JsonRead.text(json['cycleType']),
      mediaOwnerName: JsonRead.text(json['mediaOwnerName']),
      lat: JsonRead.number(json['lat']),
      lng: JsonRead.number(json['lng']),
      impressions: JsonRead.integer(json['impressions']),
    );
  }

  static UnitSummary? tryParse(Object? json) {
    final map = JsonRead.object(json);
    return map == null ? null : UnitSummary.fromJson(map);
  }

  /// Površina iz javnog inventara (`InventoryItemDto`: šifra je
  /// `vendorInventoryId`, a grad, država, tip i format su reference `{id, name}`).
  factory UnitSummary.fromInventoryJson(Map<String, dynamic> json) {
    return UnitSummary(
      id: JsonRead.integer(json['id']),
      code: JsonRead.text(json['vendorInventoryId']) ??
          JsonRead.text(json['code']),
      siteName: JsonRead.text(json['siteName']),
      address:
          JsonRead.text(json['fullAddress']) ?? JsonRead.text(json['address']),
      city: JsonRead.refName(json['city']),
      country: JsonRead.refName(json['country']),
      itemType: JsonRead.text(json['itemType']),
      mediaFormat: JsonRead.refName(json['mediaFormat']) ??
          JsonRead.text(json['vendorMediaFormatName']),
      venueType: JsonRead.refName(json['venueType']),
      unitType: JsonRead.refName(json['unitType']),
      environment: JsonRead.text(json['environment']),
      illumination: JsonRead.text(json['illumination']),
      physicalWidth: JsonRead.number(json['physicalWidth']),
      physicalHeight: JsonRead.number(json['physicalHeight']),
      sizeUnit: JsonRead.text(json['sizeUnit']),
      pixelWidth: JsonRead.integer(json['pixelWidth']),
      pixelHeight: JsonRead.integer(json['pixelHeight']),
      imageUrl: _inventoryImage(json),
      pricePerCycle: JsonRead.number(json['pricePerCycle']),
      currency: JsonRead.text(json['currency']),
      cycleType: JsonRead.text(json['cycleType']),
      mediaOwnerName: JsonRead.text(json['mediaOwnerName']) ??
          JsonRead.text(json['mediaOwnerUsername']),
      lat: JsonRead.number(json['lat']),
      lng: JsonRead.number(json['lng']),
      impressions: JsonRead.integer(json['impressions']),
      available: JsonRead.flag(json['available']) ?? true,
    );
  }

  /// Sažetak iz ravnih polja stavke kada backend ne pošalje `unit`.
  factory UnitSummary.basic({
    int? id,
    String? code,
    String? address,
    String? city,
    String? mediaOwnerName,
    String? currency,
    String? cycleType,
  }) {
    return UnitSummary(
      id: id,
      code: JsonRead.text(code),
      address: JsonRead.text(address),
      city: JsonRead.text(city),
      mediaOwnerName: JsonRead.text(mediaOwnerName),
      currency: JsonRead.text(currency),
      cycleType: JsonRead.text(cycleType),
    );
  }

  static const _imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];

  // Uvoz vlasnika ponekad u assetUrl upiše adresu prezentacije, a ne fotografiju.
  static String? _inventoryImage(Map<String, dynamic> json) {
    final direct = JsonRead.text(json['imageUrl']);
    if (direct != null) return direct;
    final images = json['images'];
    if (images is List && images.isNotEmpty) {
      final first = JsonRead.text(images.first is Map
          ? (images.first as Map)['url'] ?? (images.first as Map)['filePath']
          : images.first);
      if (first != null) return first;
    }
    final asset = JsonRead.text(json['assetUrl']);
    if (asset == null) return null;
    final lower = asset.toLowerCase();
    final isImage =
        asset.startsWith('/') || _imageExtensions.any(lower.endsWith);
    return isImage ? asset : null;
  }

  /// Naziv površine: naziv lokacije, adresa, šifra, a tek na kraju broj.
  String get title {
    for (final value in [siteName, address, code]) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return id != null ? 'Površina #$id' : 'Površina';
  }

  /// Šifra za oznaku pored naziva; prazna kada je naziv već šifra.
  String? get codeLabel {
    final c = code?.trim();
    if (c == null || c.isEmpty) return null;
    return c.toLowerCase() == title.toLowerCase() ? null : c;
  }

  /// "Beograd, Srbija"
  String get place => SrLabels.place(city, country);

  /// Red ispod naziva: "Knez Mihailova 12, Beograd, Srbija" (adresa samo kada
  /// već nije naslov).
  String get location {
    final parts = <String>[];
    final street = address?.trim();
    if (street != null && street.isNotEmpty && street != title) {
      parts.add(street);
    }
    if (place.isNotEmpty) parts.add(place);
    return parts.join(', ');
  }

  /// Statična ili digitalna, isključivo po tipu površine (`itemType` je
  /// UNIT/PACKAGE i ne prikazuje se).
  bool get isDigital => SrLabels.isDigital(unitType);

  /// Oznake svojstava: tip, format, okruženje i dimenzije (samo popunjene).
  List<String> get specs => [
        SrLabels.unitType(unitType),
        SrLabels.format(mediaFormat),
        SrLabels.venue(venueType ?? environment),
        SrLabels.dimensions(physicalWidth, physicalHeight, sizeUnit),
      ].where((s) => s.isNotEmpty).toList();

  /// Tekst za pretragu: šifra, naziv, adresa, grad, država, vlasnik i format.
  String get searchText => [
        code,
        siteName,
        address,
        city,
        SrLabels.city(city),
        country,
        SrLabels.country(country),
        mediaOwnerName,
        mediaFormat,
        SrLabels.format(mediaFormat),
        SrLabels.unitType(unitType),
      ].whereType<String>().join(' ');
}
