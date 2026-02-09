import 'package:dio/dio.dart';

import '../../../../core/config/api_client.dart';
import '../../../../core/config/api_config.dart';
import '../dto/inquiry_dto.dart';

class InquiryApiService {
  final ApiClient _apiClient;

  InquiryApiService(this._apiClient);

  // Admin endpoints
  Future<List<InquiryDto>> getAdminInquiries() async {
    final response = await _apiClient.get<List<dynamic>>(ApiConfig.adminInquiries);
    return (response.data ?? [])
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

  // Public endpoint
  Future<Map<String, dynamic>> createInquiry(Map<String, dynamic> data) async {
    final response = await _apiClient.post<Map<String, dynamic>>(
      ApiConfig.publicInquiries,
      data: data,
    );
    return response.data!;
  }
}
