import 'dictionary_ref_dto.dart';

/// Inventory Item DTO matching backend InventoryItemDto
class InventoryItemDto {
  final int id;
  final int? mediaOwnerId;
  final String? mediaOwnerUsername;
  final DictionaryRefDto? country;
  final DictionaryRefDto? city;
  final String? vendorInventoryId;
  final DictionaryRefDto? mediaFormat;
  final String? vendorMediaFormatName;
  final DictionaryRefDto? venueType;
  final DictionaryRefDto? unitType;
  final double? lat;
  final double? lng;
  final int? spotLengthSeconds;
  final int? loopLengthSeconds;
  final String? postalCode;
  final String? currency;
  final double? pricePerCycle;
  final String? cycleType;
  final String? siteName;
  final int? facingDegrees;
  final int? facesQuantity;
  final String? startTime;
  final String? endTime;
  final int? pixelWidth;
  final int? pixelHeight;
  final String? fullAddress;
  final String? description;
  final double? physicalWidth;
  final double? physicalHeight;
  final String? sizeUnit;
  final String? illumination;
  final int? impressions;
  final String? impressionType;
  final double? impressionMultiplier;
  final double? cpm;
  final String? assetUrl;
  final String? assetUrlDescription;
  final String? status;

  const InventoryItemDto({
    required this.id,
    this.mediaOwnerId,
    this.mediaOwnerUsername,
    this.country,
    this.city,
    this.vendorInventoryId,
    this.mediaFormat,
    this.vendorMediaFormatName,
    this.venueType,
    this.unitType,
    this.lat,
    this.lng,
    this.spotLengthSeconds,
    this.loopLengthSeconds,
    this.postalCode,
    this.currency,
    this.pricePerCycle,
    this.cycleType,
    this.siteName,
    this.facingDegrees,
    this.facesQuantity,
    this.startTime,
    this.endTime,
    this.pixelWidth,
    this.pixelHeight,
    this.fullAddress,
    this.description,
    this.physicalWidth,
    this.physicalHeight,
    this.sizeUnit,
    this.illumination,
    this.impressions,
    this.impressionType,
    this.impressionMultiplier,
    this.cpm,
    this.assetUrl,
    this.assetUrlDescription,
    this.status,
  });

  factory InventoryItemDto.fromJson(Map<String, dynamic> json) {
    return InventoryItemDto(
      id: json['id'] as int,
      mediaOwnerId: json['mediaOwnerId'] as int?,
      mediaOwnerUsername: json['mediaOwnerUsername'] as String?,
      country: json['country'] != null
          ? DictionaryRefDto.fromJson(json['country'] as Map<String, dynamic>)
          : null,
      city: json['city'] != null
          ? DictionaryRefDto.fromJson(json['city'] as Map<String, dynamic>)
          : null,
      vendorInventoryId: json['vendorInventoryId'] as String?,
      mediaFormat: json['mediaFormat'] != null
          ? DictionaryRefDto.fromJson(json['mediaFormat'] as Map<String, dynamic>)
          : null,
      vendorMediaFormatName: json['vendorMediaFormatName'] as String?,
      venueType: json['venueType'] != null
          ? DictionaryRefDto.fromJson(json['venueType'] as Map<String, dynamic>)
          : null,
      unitType: json['unitType'] != null
          ? DictionaryRefDto.fromJson(json['unitType'] as Map<String, dynamic>)
          : null,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      spotLengthSeconds: json['spotLengthSeconds'] as int?,
      loopLengthSeconds: json['loopLengthSeconds'] as int?,
      postalCode: json['postalCode'] as String?,
      currency: json['currency'] as String?,
      pricePerCycle: (json['pricePerCycle'] as num?)?.toDouble(),
      cycleType: json['cycleType'] as String?,
      siteName: json['siteName'] as String?,
      facingDegrees: json['facingDegrees'] as int?,
      facesQuantity: json['facesQuantity'] as int?,
      startTime: json['startTime'] as String?,
      endTime: json['endTime'] as String?,
      pixelWidth: json['pixelWidth'] as int?,
      pixelHeight: json['pixelHeight'] as int?,
      fullAddress: json['fullAddress'] as String?,
      description: json['description'] as String?,
      physicalWidth: (json['physicalWidth'] as num?)?.toDouble(),
      physicalHeight: (json['physicalHeight'] as num?)?.toDouble(),
      sizeUnit: json['sizeUnit'] as String?,
      illumination: json['illumination'] as String?,
      impressions: json['impressions'] as int?,
      impressionType: json['impressionType'] as String?,
      impressionMultiplier: (json['impressionMultiplier'] as num?)?.toDouble(),
      cpm: (json['cpm'] as num?)?.toDouble(),
      assetUrl: json['assetUrl'] as String?,
      assetUrlDescription: json['assetUrlDescription'] as String?,
      status: json['status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mediaOwnerId': mediaOwnerId,
      'mediaOwnerUsername': mediaOwnerUsername,
      'country': country?.toJson(),
      'city': city?.toJson(),
      'vendorInventoryId': vendorInventoryId,
      'mediaFormat': mediaFormat?.toJson(),
      'vendorMediaFormatName': vendorMediaFormatName,
      'venueType': venueType?.toJson(),
      'unitType': unitType?.toJson(),
      'lat': lat,
      'lng': lng,
      'spotLengthSeconds': spotLengthSeconds,
      'loopLengthSeconds': loopLengthSeconds,
      'postalCode': postalCode,
      'currency': currency,
      'pricePerCycle': pricePerCycle,
      'cycleType': cycleType,
      'siteName': siteName,
      'facingDegrees': facingDegrees,
      'facesQuantity': facesQuantity,
      'startTime': startTime,
      'endTime': endTime,
      'pixelWidth': pixelWidth,
      'pixelHeight': pixelHeight,
      'fullAddress': fullAddress,
      'description': description,
      'physicalWidth': physicalWidth,
      'physicalHeight': physicalHeight,
      'sizeUnit': sizeUnit,
      'illumination': illumination,
      'impressions': impressions,
      'impressionType': impressionType,
      'impressionMultiplier': impressionMultiplier,
      'cpm': cpm,
      'assetUrl': assetUrl,
      'assetUrlDescription': assetUrlDescription,
      'status': status,
    };
  }
}
