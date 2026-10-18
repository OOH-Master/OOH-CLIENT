import '../../../../core/utils/sr_labels.dart';
import '../../domain/entities/inquiry.dart';
import 'inquiry_dto.dart';

class InquiryMapper {
  /// [cityNames] i [mediaTypeNames] su rečnici (ID → naziv) za ciljane gradove i
  /// tipove medija iz brifa, koje backend čuva kao ID-jeve razdvojene zarezom.
  static Inquiry fromDto(
    InquiryDto dto, {
    Map<int, String> cityNames = const {},
    Map<int, String> mediaTypeNames = const {},
  }) {
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
      inquiryType: dto.inquiryType,
      requesterName: dto.requesterName,
      targetCities: dto.targetCities,
      preferredMediaTypes: dto.preferredMediaTypes,
      targetCityNames: resolveNames(dto.targetCities, cityNames, SrLabels.city),
      preferredMediaTypeNames: resolveNames(
          dto.preferredMediaTypes, mediaTypeNames, SrLabels.unitType),
      targetAudience: dto.targetAudience,
      additionalRequirements: dto.additionalRequirements,
      itemCount: dto.itemCount,
      items: dto.items
          .map((e) => InquiryItem(
                id: e.id,
                inventoryItemId: e.inventoryItemId,
                inventoryItemName: e.inventoryItemName,
                inventoryItemAddress: e.inventoryItemAddress,
                inventoryItemCity: e.inventoryItemCity,
                mediaOwnerName: e.mediaOwnerName,
                quotedPrice: e.quotedPrice,
                unit: e.unit,
                cycles: e.cycles,
                currency: e.currency,
              ))
          .toList(),
    );
  }

  /// "1,5" → ["Beograd", "Novi Sad"]. ID koji nije u rečniku se ne prikazuje
  /// (nikad sirov broj); tekst koji nije broj prikazuje se kao naziv.
  static List<String> resolveNames(
    String? raw,
    Map<int, String> names,
    String Function(String) label,
  ) {
    if (raw == null || raw.trim().isEmpty) return const [];
    final result = <String>[];
    for (final token in raw.split(',')) {
      final t = token.trim();
      if (t.isEmpty) continue;
      final id = int.tryParse(t);
      final name = id != null ? names[id] : t;
      if (name == null) continue;
      final text = label(name);
      if (text.isNotEmpty && !result.contains(text)) result.add(text);
    }
    return result;
  }
}
