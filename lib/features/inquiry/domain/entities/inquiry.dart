enum InquiryStatus {
  submitted,
  inProgress,
  quotesRequested,
  pricingReady,
  offerSent,
  acceptedByClient,
  rejectedByClient,
  realized,
  closed;

  String get apiValue {
    switch (this) {
      case InquiryStatus.submitted:
        return 'SUBMITTED';
      case InquiryStatus.inProgress:
        return 'IN_PROGRESS';
      case InquiryStatus.quotesRequested:
        return 'QUOTES_REQUESTED';
      case InquiryStatus.pricingReady:
        return 'PRICING_READY';
      case InquiryStatus.offerSent:
        return 'OFFER_SENT';
      case InquiryStatus.acceptedByClient:
        return 'ACCEPTED_BY_CLIENT';
      case InquiryStatus.rejectedByClient:
        return 'REJECTED_BY_CLIENT';
      case InquiryStatus.realized:
        return 'REALIZED';
      case InquiryStatus.closed:
        return 'CLOSED';
    }
  }

  static InquiryStatus fromApi(String? value) {
    switch (value) {
      case 'SUBMITTED':
        return InquiryStatus.submitted;
      case 'IN_PROGRESS':
        return InquiryStatus.inProgress;
      case 'QUOTES_REQUESTED':
        return InquiryStatus.quotesRequested;
      case 'PRICING_READY':
        return InquiryStatus.pricingReady;
      case 'OFFER_SENT':
        return InquiryStatus.offerSent;
      case 'ACCEPTED_BY_CLIENT':
        return InquiryStatus.acceptedByClient;
      case 'REJECTED_BY_CLIENT':
        return InquiryStatus.rejectedByClient;
      case 'REALIZED':
        return InquiryStatus.realized;
      case 'CLOSED':
        return InquiryStatus.closed;
      default:
        return InquiryStatus.submitted;
    }
  }
}

class InquiryItem {
  final int id;
  final int? inventoryItemId;
  final String? inventoryItemName;
  final String? inventoryItemAddress;
  final String? inventoryItemCity;
  final String? mediaOwnerName;
  final double? quotedPrice;

  const InquiryItem({
    required this.id,
    this.inventoryItemId,
    this.inventoryItemName,
    this.inventoryItemAddress,
    this.inventoryItemCity,
    this.mediaOwnerName,
    this.quotedPrice,
  });
}

class Inquiry {
  final int id;
  final String? requesterType;
  final InquiryStatus status;
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
  final List<InquiryItem> items;

  const Inquiry({
    required this.id,
    this.requesterType,
    required this.status,
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
    this.items = const [],
  });
}
