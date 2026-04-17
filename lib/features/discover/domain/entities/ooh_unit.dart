import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

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
  });

  bool get isAvailable => status == OohStatus.available;

  String get priceDisplay {
    final symbol = _getCurrencySymbol(currency);
    final cycle = _getCycleDisplay(cycleType);
    final formatter = NumberFormat('#,###', 'en_US');
    final formattedPrice = formatter.format(price.round());
    return '$symbol$formattedPrice/$cycle';
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency.toUpperCase()) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'RSD':
        return 'RSD ';
      default:
        return '$currency ';
    }
  }

  static String _getCycleDisplay(CycleType cycle) {
    switch (cycle) {
      case CycleType.oneDay:
        return 'day';
      case CycleType.oneWeek:
        return 'week';
      case CycleType.twoWeek:
        return '2 weeks';
      case CycleType.fourWeek:
        return '4 weeks';
      case CycleType.oneMonth:
        return 'month';
    }
  }

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
      ];
}

