class InquiryItemDto {
  final int id;
  final int? inventoryItemId;
  final String? inventoryItemName;
  final String? inventoryItemAddress;
  final String? inventoryItemCity;
  final String? mediaOwnerName;
  final double? quotedPrice;

  const InquiryItemDto({
    required this.id,
    this.inventoryItemId,
    this.inventoryItemName,
    this.inventoryItemAddress,
    this.inventoryItemCity,
    this.mediaOwnerName,
    this.quotedPrice,
  });

  factory InquiryItemDto.fromJson(Map<String, dynamic> json) {
    return InquiryItemDto(
      id: json['id'] as int,
      inventoryItemId: json['inventoryItemId'] as int?,
      inventoryItemName: json['inventoryItemName'] as String?,
      inventoryItemAddress: json['inventoryItemAddress'] as String?,
      inventoryItemCity: json['inventoryItemCity'] as String?,
      mediaOwnerName: json['mediaOwnerName'] as String?,
      quotedPrice: (json['quotedPrice'] as num?)?.toDouble(),
    );
  }
}

class InquiryDto {
  final int id;
  final String? requesterType;
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
  final String? pdfFileName;
  final String? createdAt;
  final int itemCount;
  final List<InquiryItemDto> items;

  const InquiryDto({
    required this.id,
    this.requesterType,
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
    this.pdfFileName,
    this.createdAt,
    this.itemCount = 0,
    this.items = const [],
  });

  factory InquiryDto.fromJson(Map<String, dynamic> json) {
    return InquiryDto(
      id: json['id'] as int,
      requesterType: json['requesterType'] as String?,
      status: json['status'] as String?,
      brandId: json['brandId'] as int?,
      agencyId: json['agencyId'] as int?,
      contactName: json['contactName'] as String?,
      contactEmail: json['contactEmail'] as String?,
      contactPhone: json['contactPhone'] as String?,
      campaignBrief: json['campaignBrief'] as String?,
      adminNotes: json['adminNotes'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      pdfFileName: json['pdfFileName'] as String?,
      createdAt: json['createdAt'] as String?,
      itemCount: json['itemCount'] as int? ?? 0,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => InquiryItemDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
