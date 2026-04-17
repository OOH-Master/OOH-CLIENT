import 'package:dio/dio.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/inquiry_dto.dart';

class InquiryApiService {
  final ApiClient _apiClient;

  InquiryApiService(this._apiClient);

  // Admin endpoints
  Future<List<InquiryDto>> getAdminInquiries({
    String? status,
    String? requesterType,
    String? search,
  }) async {
    final queryParams = <String, dynamic>{};
    if (status != null) queryParams['status'] = status;
    if (requesterType != null) queryParams['requesterType'] = requesterType;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    queryParams['size'] = 100;

    final response = await _apiClient.get<Map<String, dynamic>>(
      ApiConfig.adminInquiries,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    // Backend returns Spring Page<InquiryDto> with content array
    final content = (response.data?['content'] as List<dynamic>?) ?? [];
    return content
        .map((json) => InquiryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InquiryDto> getAdminInquiryById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.adminInquiries}/$id',
    );
    return InquiryDto.fromJson(response.data!);
  }

  Future<void> updateAdminNotes(int id, String notes) async {
    await _apiClient.put(
      '${ApiConfig.adminInquiries}/$id/admin-notes',
      data: {'notes': notes},
    );
  }

  Future<void> updateQuotedPrice(int inquiryId, int itemId, double price) async {
    await _apiClient.put(
      '${ApiConfig.adminInquiries}/$inquiryId/items/$itemId/quoted-price',
      data: {'quotedPrice': price},
    );
  }

  Future<Response<List<int>>> downloadPdf(int id) async {
    return _apiClient.get<List<int>>(
      '${ApiConfig.adminInquiries}/$id/pdf',
      options: Options(responseType: ResponseType.bytes),
    );
  }

  /// Downloads the invoice PDF for a given invoiceId.
  Future<Response<List<int>>> downloadInvoicePdf(int invoiceId) async {
    return _apiClient.get<List<int>>(
      ApiConfig.invoicePdf(invoiceId),
      options: Options(responseType: ResponseType.bytes),
    );
  }

  /// Returns the invoice associated with a campaign (if exists).
  Future<Map<String, dynamic>?> getInvoiceForCampaign(int campaignId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.invoicesByCampaign(campaignId),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  /// Returns the invoice associated with an inquiry (if exists).
  Future<Map<String, dynamic>?> getInvoiceForInquiry(int inquiryId) async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        ApiConfig.invoicesByInquiry(inquiryId),
      );
      return response.data;
    } catch (e) {
      return null;
    }
  }

  Future<void> transitionStatus(int id, String newStatus) async {
    await _apiClient.put(
      '${ApiConfig.adminInquiries}/$id/status',
      data: {'status': newStatus},
    );
  }

  Future<void> requestQuotes(int id) async {
    await _apiClient.post('${ApiConfig.adminInquiries}/$id/request-quotes');
  }

  Future<void> sendOffer(int id) async {
    await _apiClient.post('${ApiConfig.adminInquiries}/$id/send-offer');
  }

  Future<void> assignUnits(int inquiryId, List<int> unitIds) async {
    await _apiClient.post(
      '${ApiConfig.adminInquiries}/$inquiryId/assign-units',
      data: {'unitIds': unitIds},
    );
  }

  // Brand endpoints
  Future<List<InquiryDto>> getBrandInquiries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.brandInquiries);
    return (response.data ?? [])
        .map((json) => InquiryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InquiryDto> getBrandInquiryById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.brandInquiries}/$id',
    );
    return InquiryDto.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getBrandOffer(int inquiryId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.brandInquiries}/$inquiryId/offer',
    );
    return response.data ?? {};
  }

  Future<int?> acceptBrandOffer(int inquiryId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.brandInquiries}/$inquiryId/offer/accept',
    );
    return response.data?['campaignId'] as int?;
  }

  Future<void> rejectBrandOffer(int inquiryId, String? reason) async {
    await _apiClient.post(
      '${ApiConfig.brandInquiries}/$inquiryId/offer/reject',
      data: reason != null ? {'reason': reason} : null,
    );
  }

  // Agency endpoints
  Future<List<InquiryDto>> getAgencyInquiries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.agencyInquiries);
    return (response.data ?? [])
        .map((json) => InquiryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InquiryDto> getAgencyInquiryById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.agencyInquiries}/$id',
    );
    return InquiryDto.fromJson(response.data!);
  }

  Future<Map<String, dynamic>> getAgencyOffer(int inquiryId) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.agencyInquiries}/$inquiryId/offer',
    );
    return response.data ?? {};
  }

  Future<int?> acceptAgencyOffer(int inquiryId) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      '${ApiConfig.agencyInquiries}/$inquiryId/offer/accept',
    );
    return response.data?['campaignId'] as int?;
  }

  Future<void> rejectAgencyOffer(int inquiryId, String? reason) async {
    await _apiClient.post(
      '${ApiConfig.agencyInquiries}/$inquiryId/offer/reject',
      data: reason != null ? {'reason': reason} : null,
    );
  }

  // Media Owner endpoints
  Future<List<InquiryDto>> getMediaOwnerInquiries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.mediaOwnerInquiries);
    return (response.data ?? [])
        .map((json) => InquiryDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<InquiryDto> getMediaOwnerInquiryById(int id) async {
    final response = await _apiClient.get<Map<String, dynamic>>(
      '${ApiConfig.mediaOwnerInquiries}/$id',
    );
    return InquiryDto.fromJson(response.data!);
  }

  Future<List<Map<String, dynamic>>> getMediaOwnerQuotes() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.mediaOwnerQuotes);
    return (response.data ?? [])
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Future<void> submitQuote(int quoteId) async {
    await _apiClient.post('${ApiConfig.mediaOwnerQuotes}/$quoteId/submit');
  }

  Future<void> declineQuote(int quoteId) async {
    await _apiClient.post('${ApiConfig.mediaOwnerQuotes}/$quoteId/decline');
  }

  Future<void> updateQuoteItem(int quoteId, int itemId, Map<String, dynamic> data) async {
    await _apiClient.put(
      '${ApiConfig.mediaOwnerQuotes}/$quoteId/items/$itemId',
      data: data,
    );
  }

  // Public endpoint
  Future<Map<String, dynamic>> createInquiry(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.publicInquiries,
      data: data,
    );
    return response.data ?? {};
  }
}
