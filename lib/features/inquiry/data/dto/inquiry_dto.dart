import '../../domain/entities/unit_summary.dart';
import 'json_read.dart';

class InquiryItemDto {
  final int id;
  final int? inventoryItemId;
  final String? inventoryItemName;
  final String? inventoryItemAddress;
  final String? inventoryItemCity;
  final String? mediaOwnerName;
  final double? quotedPrice;

  /// Sažetak površine (`unit`); stariji backend ga ne šalje.
  final UnitSummary? unit;

  /// Broj ciklusa zakupa za period upita.
  final int? cycles;

  /// Valuta u kojoj je izražena [quotedPrice].
  final String? currency;

  const InquiryItemDto({
    required this.id,
    this.inventoryItemId,
    this.inventoryItemName,
    this.inventoryItemAddress,
    this.inventoryItemCity,
    this.mediaOwnerName,
    this.quotedPrice,
    this.unit,
    this.cycles,
    this.currency,
  });

  factory InquiryItemDto.fromJson(Map<String, dynamic> json) {
    return InquiryItemDto(
      id: JsonRead.integer(json['id']) ?? 0,
      inventoryItemId: JsonRead.integer(json['inventoryItemId']),
      inventoryItemName: JsonRead.text(json['inventoryItemName']),
      inventoryItemAddress: JsonRead.text(json['inventoryItemAddress']),
      inventoryItemCity: JsonRead.text(json['inventoryItemCity']),
      mediaOwnerName: JsonRead.text(json['mediaOwnerName']),
      quotedPrice: JsonRead.number(json['quotedPrice']),
      unit: UnitSummary.tryParse(json['unit']),
      cycles: JsonRead.integer(json['cycles']),
      currency: JsonRead.text(json['currency']),
    );
  }
}

class InquiryDto {
  final int id;
  final String? requesterType;
  final String? inquiryType;
  final String? status;
  final int? brandId;
  final int? agencyId;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? campaignBrief;
  final String? adminNotes;
  final String? startDate;
  final String? endDate;
  final double? budget;
  final String? targetCities;
  final String? preferredMediaTypes;
  final String? targetAudience;
  final String? additionalRequirements;
  final String? pdfFileName;
  final String? createdAt;
  final int itemCount;
  final List<InquiryItemDto> items;

  /// Naziv brenda, zatim agencije, a ako ih nema, ime kontakt osobe.
  final String? requesterName;

  const InquiryDto({
    required this.id,
    this.requesterType,
    this.inquiryType,
    this.status,
    this.brandId,
    this.agencyId,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.campaignBrief,
    this.adminNotes,
    this.startDate,
    this.endDate,
    this.budget,
    this.targetCities,
    this.preferredMediaTypes,
    this.targetAudience,
    this.additionalRequirements,
    this.pdfFileName,
    this.createdAt,
    this.itemCount = 0,
    this.items = const [],
    this.requesterName,
  });

  factory InquiryDto.fromJson(Map<String, dynamic> json) {
    return InquiryDto(
      id: JsonRead.integer(json['id']) ?? 0,
      requesterType: JsonRead.text(json['requesterType']),
      inquiryType: JsonRead.text(json['inquiryType']),
      status: JsonRead.text(json['status']),
      brandId: JsonRead.integer(json['brandId']),
      agencyId: JsonRead.integer(json['agencyId']),
      contactName: JsonRead.text(json['contactName']),
      contactEmail: JsonRead.text(json['contactEmail']),
      contactPhone: JsonRead.text(json['contactPhone']),
      campaignBrief: JsonRead.text(json['campaignBrief']),
      adminNotes: json['adminNotes'] as String?,
      startDate: JsonRead.text(json['startDate']),
      endDate: JsonRead.text(json['endDate']),
      budget: JsonRead.number(json['budget']),
      targetCities: _joined(json['targetCities']),
      preferredMediaTypes: _joined(json['preferredMediaTypes']),
      targetAudience: JsonRead.text(json['targetAudience']),
      additionalRequirements: JsonRead.text(json['additionalRequirements']),
      pdfFileName: JsonRead.text(json['pdfFileName']),
      createdAt: JsonRead.text(json['createdAt']),
      itemCount: JsonRead.integer(json['itemCount']) ?? 0,
      items:
          JsonRead.objects(json['items']).map(InquiryItemDto.fromJson).toList(),
      requesterName: JsonRead.text(json['requesterName']),
    );
  }

  // Backend čuva listu kao tekst ("1,5"); ako jednom stigne kao niz, spaja se.
  static String? _joined(Object? value) {
    if (value is List) {
      final parts = value
          .map((e) => e is Map ? (e['id'] ?? e['name']) : e)
          .map(JsonRead.text)
          .whereType<String>()
          .toList();
      return parts.isEmpty ? null : parts.join(',');
    }
    return JsonRead.text(value);
  }
}
