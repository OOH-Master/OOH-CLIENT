import '../../../auth/domain/entities/role.dart';
import '../../domain/entities/inquiry.dart';
import '../api/inquiry_api_service.dart';
import '../dto/inquiry_mapper.dart';

/// Data class for quote information
class QuoteData {
  final int id;
  final int inquiryId;
  final String status;
  final List<QuoteItemData> items;

  const QuoteData({
    required this.id,
    required this.inquiryId,
    required this.status,
    this.items = const [],
  });

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    return QuoteData(
      id: json['id'] as int? ?? 0,
      inquiryId: json['inquiryId'] as int? ?? 0,
      status: json['status'] as String? ?? 'NEW',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => QuoteItemData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class QuoteItemData {
  final int id;
  final String? inventoryName;
  final double? price;

  const QuoteItemData({
    required this.id,
    this.inventoryName,
    this.price,
  });

  factory QuoteItemData.fromJson(Map<String, dynamic> json) {
    return QuoteItemData(
      id: json['id'] as int? ?? 0,
      inventoryName: json['inventoryName'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }
}

/// Data class for offer information
class OfferData {
  final int inquiryId;
  final String? createdAt;
  final List<OfferItemData> items;

  const OfferData({
    required this.inquiryId,
    this.createdAt,
    this.items = const [],
  });

  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      inquiryId: json['inquiryId'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => OfferItemData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class OfferItemData {
  final int id;
  final String? unitName;
  final double? finalPrice;
  final String? currency;

  const OfferItemData({
    required this.id,
    this.unitName,
    this.finalPrice,
    this.currency,
  });

  factory OfferItemData.fromJson(Map<String, dynamic> json) {
    return OfferItemData(
      id: json['id'] as int? ?? 0,
      unitName: json['unitName'] as String? ?? json['inventoryName'] as String?,
      finalPrice: (json['finalPrice'] as num?)?.toDouble() ??
          (json['quotedPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}

class InquiryRepository {
  final InquiryApiService _apiService;

  InquiryRepository(this._apiService);

  Future<List<Inquiry>> getInquiries(Role role) async {
    final dtos = switch (role) {
      Role.admin => await _apiService.getAdminInquiries(),
      Role.brand => await _apiService.getBrandInquiries(),
      Role.agency => await _apiService.getAgencyInquiries(),
      Role.mediaOwner => await _apiService.getMediaOwnerInquiries(),
    };
    return dtos.map((dto) => InquiryMapper.fromDto(dto)).toList();
  }

  Future<Inquiry> getInquiryById(int id, Role role) async {
    final dto = switch (role) {
      Role.admin => await _apiService.getAdminInquiryById(id),
      Role.brand => await _apiService.getBrandInquiryById(id),
      Role.agency => await _apiService.getAgencyInquiryById(id),
      Role.mediaOwner => await _apiService.getMediaOwnerInquiryById(id),
    };
    return InquiryMapper.fromDto(dto);
  }

  Future<void> updateAdminNotes(int id, String notes) async {
    await _apiService.updateAdminNotes(id, notes);
  }

  Future<void> updateQuotedPrice(int inquiryId, int itemId, double price) async {
    await _apiService.updateQuotedPrice(inquiryId, itemId, price);
  }

  Future<List<int>?> downloadPdf(int id) async {
    final response = await _apiService.downloadPdf(id);
    return response.data;
  }

  Future<List<int>?> downloadInvoicePdf(int invoiceId) async {
    final response = await _apiService.downloadInvoicePdf(invoiceId);
    return response.data;
  }

  Future<Map<String, dynamic>?> getInvoiceForCampaign(int campaignId) =>
      _apiService.getInvoiceForCampaign(campaignId);

  Future<Map<String, dynamic>?> getInvoiceForInquiry(int inquiryId) =>
      _apiService.getInvoiceForInquiry(inquiryId);

  Future<void> createInquiry(Map<String, dynamic> data) async {
    await _apiService.createInquiry(data);
  }

  Future<void> transitionStatus(int id, String newStatus) async {
    await _apiService.transitionStatus(id, newStatus);
  }

  Future<void> requestQuotes(int id) async {
    await _apiService.requestQuotes(id);
  }

  Future<void> sendOffer(int id) async {
    await _apiService.sendOffer(id);
  }

  Future<void> assignUnits(int inquiryId, List<int> unitIds) async {
    await _apiService.assignUnits(inquiryId, unitIds);
  }

  Future<List<QuoteData>> getMediaOwnerQuotes() async {
    final data = await _apiService.getMediaOwnerQuotes();
    return data.map((e) => QuoteData.fromJson(e)).toList();
  }

  Future<void> submitQuote(int quoteId) async {
    await _apiService.submitQuote(quoteId);
  }

  Future<void> declineQuote(int quoteId) async {
    await _apiService.declineQuote(quoteId);
  }

  Future<void> updateQuoteItem(int quoteId, int itemId, Map<String, dynamic> data) async {
    await _apiService.updateQuoteItem(quoteId, itemId, data);
  }

  Future<OfferData> getOffer(int inquiryId, Role role) async {
    final data = switch (role) {
      Role.brand => await _apiService.getBrandOffer(inquiryId),
      Role.agency => await _apiService.getAgencyOffer(inquiryId),
      _ => throw Exception('Only brands and agencies can view offers'),
    };
    return OfferData.fromJson(data);
  }

  Future<int?> acceptOffer(int inquiryId, Role role) async {
    switch (role) {
      case Role.brand:
        return await _apiService.acceptBrandOffer(inquiryId);
      case Role.agency:
        return await _apiService.acceptAgencyOffer(inquiryId);
      default:
        throw Exception('Only brands and agencies can accept offers');
    }
  }

  Future<void> rejectOffer(int inquiryId, String? reason, Role role) async {
    switch (role) {
      case Role.brand:
        await _apiService.rejectBrandOffer(inquiryId, reason);
        break;
      case Role.agency:
        await _apiService.rejectAgencyOffer(inquiryId, reason);
        break;
      default:
        throw Exception('Only brands and agencies can reject offers');
    }
  }
}
