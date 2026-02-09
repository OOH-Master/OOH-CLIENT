import '../../../auth/domain/entities/role.dart';
import '../../domain/entities/inquiry.dart';
import '../api/inquiry_api_service.dart';
import '../dto/inquiry_mapper.dart';

class InquiryRepository {
  final InquiryApiService _apiService;

  InquiryRepository(this._apiService);

  Future<List<Inquiry>> getInquiries(Role role) async {
    final dtos = switch (role) {
      Role.admin => await _apiService.getAdminInquiries(),
      Role.brand => await _apiService.getBrandInquiries(),
      Role.agency => await _apiService.getAgencyInquiries(),
      Role.mediaOwner => throw Exception('Media owners do not have inquiries'),
    };
    return dtos.map((dto) => InquiryMapper.fromDto(dto)).toList();
  }

  Future<Inquiry> getInquiryById(int id, Role role) async {
    final dto = switch (role) {
      Role.admin => await _apiService.getAdminInquiryById(id),
      Role.brand => await _apiService.getBrandInquiryById(id),
      Role.agency => await _apiService.getAgencyInquiryById(id),
      Role.mediaOwner => throw Exception('Media owners do not have inquiries'),
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
}
