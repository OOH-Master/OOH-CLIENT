import '../../domain/entities/inquiry.dart';
import 'inquiry_dto.dart';

class InquiryMapper {
  static Inquiry fromDto(InquiryDto dto) {
    return Inquiry(
      id: dto.id,
      requesterType: dto.requesterType,
      status: InquiryStatus.fromApi(dto.status),
      contactName: dto.contactName,
      contactEmail: dto.contactEmail,
      contactPhone: dto.contactPhone,
      campaignBrief: dto.campaignBrief,
      adminNotes: dto.adminNotes,
      startDate: dto.startDate,
      endDate: dto.endDate,
      budget: dto.budget,
      pdfFileName: dto.pdfFileName,
      createdAt: dto.createdAt,
      items: dto.items
          .map((e) => InquiryItem(
                id: e.id,
                inventoryItemId: e.inventoryItemId,
                inventoryItemName: e.inventoryItemName,
                inventoryItemAddress: e.inventoryItemAddress,
                inventoryItemCity: e.inventoryItemCity,
                mediaOwnerName: e.mediaOwnerName,
                quotedPrice: e.quotedPrice,
              ))
          .toList(),
    );
  }
}
