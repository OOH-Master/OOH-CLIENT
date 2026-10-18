import 'package:equatable/equatable.dart';

import '../../../../core/utils/sr_format.dart';

enum OohType { billboard, digital, subway, airport, bus, other }

enum OohStatus { available, booked, maintenance }

enum CycleType { oneDay, oneWeek, twoWeek, fourWeek, oneMonth }

class OohUnit extends Equatable {
  final String id;
  final String name;
  final OohType type;
  final String address;
  final String cityId;
  final String cityName;
  final double latitude;
  final double longitude;
  final double price;
  final String currency;
  final CycleType cycleType;
  final String? imageUrl;
  final List<String> images;
  final OohStatus status;
  final DateTime? availableFrom;
  final String? description;
  final Map<String, dynamic>? specifications;
  final String? mediaOwnerName;
  final bool favorited;

  // Podaci za bogatiji prikaz površine; svi su opcioni, pa postojeći pozivi rade.
  /// Šifra površine kod vlasnika (vendorInventoryId), npr. "LiD95".
  final String? code;
  final String? countryName;

  /// Tip iz rečnika: "Static", "Digital (moving image)"...
  final String? unitTypeName;

  /// Format iz rečnika ("CLP", "Billboard"), a kada ga nema naziv vlasnika.
  final String? mediaFormatName;

  /// Naziv formata kako ga vodi vlasnik ("megaboard", "Digital Citylight").
  final String? vendorFormatName;
  final String? venueTypeName;
  final String? environment;
  final String? illumination;
  final double? physicalWidth;
  final double? physicalHeight;
  final String? sizeUnit;
  final int? pixelWidth;
  final int? pixelHeight;
  final int? impressions;

  const OohUnit({
    required this.id,
    required this.name,
    required this.type,
    required this.address,
    required this.cityId,
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.price,
    this.currency = 'USD',
    this.cycleType = CycleType.oneMonth,
    this.imageUrl,
    this.images = const [],
    required this.status,
    this.availableFrom,
    this.description,
    this.specifications,
    this.mediaOwnerName,
    this.favorited = false,
    this.code,
    this.countryName,
    this.unitTypeName,
    this.mediaFormatName,
    this.vendorFormatName,
    this.venueTypeName,
    this.environment,
    this.illumination,
    this.physicalWidth,
    this.physicalHeight,
    this.sizeUnit,
    this.pixelWidth,
    this.pixelHeight,
    this.impressions,
  });

  bool get isAvailable => status == OohStatus.available;

  /// Cena je poznata (uvoz bez cene daje 0).
  bool get hasPrice => price > 0;

  /// "180 € / 4 nedelje"; bez cene "Cena na upit".
  String get priceDisplay => hasPrice
      ? SrFormat.priceWithCycle(price, currency, cycleType.name)
      : 'Cena na upit';

  factory OohUnit.fromJson(Map<String, dynamic> json) {
    return OohUnit(
      id: json['id'].toString(),
      name: json['name'] as String,
      type: _parseType(json['type'] as String?),
      address: json['address'] as String,
      cityId: json['cityId'].toString(),
      cityName: json['cityName'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      cycleType: _parseCycleType(json['cycleType'] as String?),
      imageUrl: json['imageUrl'] as String?,
      images: (json['images'] as List?)?.cast<String>() ?? [],
      status: _parseStatus(json['status'] as String?),
      availableFrom: json['availableFrom'] != null
          ? DateTime.parse(json['availableFrom'] as String)
          : null,
      description: json['description'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      mediaOwnerName: json['mediaOwnerName'] as String?,
      favorited: json['favorited'] as bool? ?? false,
      code: json['code'] as String?,
      countryName: json['countryName'] as String?,
      unitTypeName: json['unitTypeName'] as String?,
      mediaFormatName: json['mediaFormatName'] as String?,
      vendorFormatName: json['vendorFormatName'] as String?,
      venueTypeName: json['venueTypeName'] as String?,
      environment: json['environment'] as String?,
      illumination: json['illumination'] as String?,
      physicalWidth: (json['physicalWidth'] as num?)?.toDouble(),
      physicalHeight: (json['physicalHeight'] as num?)?.toDouble(),
      sizeUnit: json['sizeUnit'] as String?,
      pixelWidth: (json['pixelWidth'] as num?)?.toInt(),
      pixelHeight: (json['pixelHeight'] as num?)?.toInt(),
      impressions: (json['impressions'] as num?)?.toInt(),
    );
  }

  static CycleType _parseCycleType(String? cycle) {
    switch (cycle?.toLowerCase()) {
      case '1-day':
      case 'one_day':
        return CycleType.oneDay;
      case '1-week':
      case 'one_week':
        return CycleType.oneWeek;
      case '2-week':
      case 'two_week':
        return CycleType.twoWeek;
      case '4-week':
      case 'four_week':
        return CycleType.fourWeek;
      case '1-month':
      case 'one_month':
      default:
        return CycleType.oneMonth;
    }
  }

  static OohType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'billboard':
        return OohType.billboard;
      case 'digital':
        return OohType.digital;
      case 'subway':
        return OohType.subway;
      case 'airport':
        return OohType.airport;
      case 'bus':
        return OohType.bus;
      default:
        return OohType.other;
    }
  }

  static OohStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return OohStatus.available;
      case 'booked':
        return OohStatus.booked;
      case 'maintenance':
        return OohStatus.maintenance;
      default:
        return OohStatus.available;
    }
  }

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        address,
        cityId,
        cityName,
        latitude,
        longitude,
        price,
        currency,
        cycleType,
        imageUrl,
        images,
        status,
        availableFrom,
        description,
        specifications,
        mediaOwnerName,
        favorited,
        code,
        countryName,
        unitTypeName,
        mediaFormatName,
        vendorFormatName,
        venueTypeName,
        environment,
        illumination,
        physicalWidth,
        physicalHeight,
        sizeUnit,
        pixelWidth,
        pixelHeight,
        impressions,
      ];
}
