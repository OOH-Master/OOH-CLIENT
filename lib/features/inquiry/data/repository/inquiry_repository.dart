import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import '../../../auth/domain/entities/role.dart';
import '../../domain/entities/currency_totals.dart';
import '../../domain/entities/inquiry.dart';
import '../../domain/entities/unit_summary.dart';
import '../api/inquiry_api_service.dart';
import '../dto/inquiry_dto.dart';
import '../dto/inquiry_mapper.dart';
import '../dto/json_read.dart';

/// Ponuda vlasnika medija za jedan upit (samo njegove površine).
class QuoteData {
  final int id;
  final int inquiryId;

  /// NEW | IN_PROGRESS | SUBMITTED | DECLINED
  final String status;
  final List<QuoteItemData> items;
  final int? mediaOwnerId;
  final String? mediaOwnerName;
  final String? submittedAt;
  final String? createdAt;

  // Kontekst upita na koji vlasnik odgovara
  final String? inquiryType;
  final String? inquiryStatus;
  final String? startDate;
  final String? endDate;
  final String? requesterType;
  final String? requesterName;
  final String? contactName;
  final String? campaignBrief;

  /// Zbir cena stavki po valuti, kako ga računa server.
  final Map<String, double> totalsByCurrency;

  const QuoteData({
    required this.id,
    required this.inquiryId,
    required this.status,
    this.items = const [],
    this.mediaOwnerId,
    this.mediaOwnerName,
    this.submittedAt,
    this.createdAt,
    this.inquiryType,
    this.inquiryStatus,
    this.startDate,
    this.endDate,
    this.requesterType,
    this.requesterName,
    this.contactName,
    this.campaignBrief,
    this.totalsByCurrency = const {},
  });

  factory QuoteData.fromJson(Map<String, dynamic> json) {
    return QuoteData(
      id: JsonRead.integer(json['id']) ?? 0,
      inquiryId: JsonRead.integer(json['inquiryId']) ?? 0,
      status: (JsonRead.text(json['status']) ?? 'NEW').toUpperCase(),
      items:
          JsonRead.objects(json['items']).map(QuoteItemData.fromJson).toList(),
      mediaOwnerId: JsonRead.integer(json['mediaOwnerId']),
      mediaOwnerName: JsonRead.text(json['mediaOwnerName']),
      submittedAt: JsonRead.text(json['submittedAt']),
      createdAt: JsonRead.text(json['createdAt']),
      inquiryType: JsonRead.text(json['inquiryType']),
      inquiryStatus: JsonRead.text(json['inquiryStatus']),
      startDate: JsonRead.text(json['startDate']),
      endDate: JsonRead.text(json['endDate']),
      requesterType: JsonRead.text(json['requesterType']),
      requesterName: JsonRead.text(json['requesterName']),
      contactName: JsonRead.text(json['contactName']),
      campaignBrief: JsonRead.text(json['campaignBrief']),
      totalsByCurrency: JsonRead.totals(json['totalsByCurrency']),
    );
  }

  /// Vlasnik još može da menja cene i odgovori na zahtev.
  bool get isEditable => status == 'NEW' || status == 'IN_PROGRESS';

  int? get days => SrFormat.days(startDate, endDate);

  /// Klijent: naziv brenda ili agencije, a ako ga nema, kontakt osoba.
  String? get clientName => requesterName ?? contactName;

  /// Zbir po valuti sa servera; ako ga nema (stariji backend), iz cena stavki.
  Map<String, double> get totals => totalsByCurrency.isNotEmpty
      ? totalsByCurrency
      : CurrencyTotals.sum(items, (i) => i.price, (i) => i.priceCurrency);
}

class QuoteItemData {
  final int id;
  final int? unitId;

  /// Šifra površine (backend je šalje kao `unitName`).
  final String? unitName;
  final double? price;
  final String? currency;
  final String? cycleType;
  final String? notes;
  final UnitSummary? unit;

  /// Broj ciklusa zakupa za period upita.
  final int? cycles;

  /// Cena iz cenovnika za ceo period (cena po ciklusu × broj ciklusa).
  final double? listPrice;

  const QuoteItemData({
    required this.id,
    this.unitId,
    this.unitName,
    this.price,
    this.currency,
    this.cycleType,
    this.notes,
    this.unit,
    this.cycles,
    this.listPrice,
  });

  factory QuoteItemData.fromJson(Map<String, dynamic> json) {
    return QuoteItemData(
      id: JsonRead.integer(json['id']) ?? 0,
      unitId: JsonRead.integer(json['unitId']),
      unitName: JsonRead.text(json['unitName']) ??
          JsonRead.text(json['inventoryName']),
      price: JsonRead.number(json['price']),
      currency: JsonRead.text(json['currency']),
      cycleType: JsonRead.text(json['cycleType']),
      notes: JsonRead.text(json['notes']),
      unit: UnitSummary.tryParse(json['unit']),
      cycles: JsonRead.integer(json['cycles']),
      listPrice: JsonRead.number(json['listPrice']),
    );
  }

  UnitSummary get summary =>
      unit ?? UnitSummary.basic(id: unitId, code: unitName, currency: currency);

  String? get priceCurrency => currency ?? unit?.currency;

  String? get effectiveCycleType => cycleType ?? unit?.cycleType;
}

/// Objedinjena ponuda: sve površine svih vlasnika medija za jedan upit.
class OfferData {
  final int? id;
  final int inquiryId;

  /// DRAFT | SENT | ACCEPTED | REJECTED
  final String? status;
  final String? generatedAt;
  final int? campaignId;

  /// Ukupno po valuti. `totalAmount` sa servera sabira sve valute u jedan broj,
  /// pa se ne prikazuje.
  final Map<String, double> totalsByCurrency;
  final String? startDate;
  final String? endDate;
  final String? inquiryType;
  final String? requesterType;
  final String? requesterName;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final double? budget;
  final int itemCount;
  final int mediaOwnerCount;
  final int cityCount;
  final List<OfferItemData> items;

  const OfferData({
    this.id,
    required this.inquiryId,
    this.status,
    this.generatedAt,
    this.campaignId,
    this.totalsByCurrency = const {},
    this.startDate,
    this.endDate,
    this.inquiryType,
    this.requesterType,
    this.requesterName,
    this.contactName,
    this.contactEmail,
    this.contactPhone,
    this.budget,
    this.itemCount = 0,
    this.mediaOwnerCount = 0,
    this.cityCount = 0,
    this.items = const [],
  });

  factory OfferData.fromJson(Map<String, dynamic> json) {
    return OfferData(
      id: JsonRead.integer(json['id']),
      inquiryId: JsonRead.integer(json['inquiryId']) ?? 0,
      status: JsonRead.text(json['status'])?.toUpperCase(),
      generatedAt: JsonRead.text(json['generatedAt']) ??
          JsonRead.text(json['createdAt']),
      campaignId: JsonRead.integer(json['campaignId']),
      totalsByCurrency: JsonRead.totals(json['totalsByCurrency']),
      startDate: JsonRead.text(json['startDate']),
      endDate: JsonRead.text(json['endDate']),
      inquiryType: JsonRead.text(json['inquiryType']),
      requesterType: JsonRead.text(json['requesterType']),
      requesterName: JsonRead.text(json['requesterName']),
      contactName: JsonRead.text(json['contactName']),
      contactEmail: JsonRead.text(json['contactEmail']),
      contactPhone: JsonRead.text(json['contactPhone']),
      budget: JsonRead.number(json['budget']),
      itemCount: JsonRead.integer(json['itemCount']) ?? 0,
      mediaOwnerCount: JsonRead.integer(json['mediaOwnerCount']) ?? 0,
      cityCount: JsonRead.integer(json['cityCount']) ?? 0,
      items:
          JsonRead.objects(json['items']).map(OfferItemData.fromJson).toList(),
    );
  }

  /// Ranije ime polja; backend šalje `generatedAt`.
  String? get createdAt => generatedAt;

  /// Klijent još nije odlučio (stariji backend ne šalje status).
  bool get awaitsDecision => status == null || status == 'SENT';

  bool get isAccepted => status == 'ACCEPTED';

  bool get isRejected => status == 'REJECTED';

  int? get days => SrFormat.days(startDate, endDate);

  /// Ukupno po valuti; ako ga server ne pošalje, sabira se iz stavki po valuti.
  Map<String, double> get totals => totalsByCurrency.isNotEmpty
      ? totalsByCurrency
      : CurrencyTotals.sum(items, (i) => i.finalPrice, (i) => i.priceCurrency);

  int get unitCount => itemCount > 0 ? itemCount : items.length;

  int get ownerCount => mediaOwnerCount > 0 ? mediaOwnerCount : groups.length;

  int get citiesCount {
    if (cityCount > 0) return cityCount;
    return items
        .map((i) => SrLabels.city(i.summary.city))
        .where((c) => c.isNotEmpty)
        .toSet()
        .length;
  }

  /// Stavke grupisane po vlasniku medija, redosledom prvog pojavljivanja.
  List<OfferOwnerGroup> get groups {
    final byOwner = <String, List<OfferItemData>>{};
    final names = <String, String?>{};
    for (final item in items) {
      final key = item.mediaOwnerId?.toString() ?? item.ownerName ?? '';
      byOwner.putIfAbsent(key, () => []).add(item);
      names[key] ??= item.ownerName;
    }
    return byOwner.entries
        .map((e) => OfferOwnerGroup(name: names[e.key], items: e.value))
        .toList();
  }
}

class OfferOwnerGroup {
  final String? name;
  final List<OfferItemData> items;

  const OfferOwnerGroup({required this.name, required this.items});

  String get displayName =>
      (name == null || name!.isEmpty) ? 'Vlasnik medija' : name!;

  Map<String, double> get totals =>
      CurrencyTotals.sum(items, (i) => i.finalPrice, (i) => i.priceCurrency);
}

class OfferItemData {
  final int id;
  final int? mediaOwnerId;
  final String? mediaOwnerName;
  final int? unitId;

  /// Šifra površine.
  final String? unitName;
  final double? finalPrice;
  final String? currency;
  final String? cycleType;
  final UnitSummary? unit;

  /// Broj ciklusa zakupa za period upita.
  final int? cycles;

  const OfferItemData({
    required this.id,
    this.mediaOwnerId,
    this.mediaOwnerName,
    this.unitId,
    this.unitName,
    this.finalPrice,
    this.currency,
    this.cycleType,
    this.unit,
    this.cycles,
  });

  factory OfferItemData.fromJson(Map<String, dynamic> json) {
    return OfferItemData(
      id: JsonRead.integer(json['id']) ?? 0,
      mediaOwnerId: JsonRead.integer(json['mediaOwnerId']),
      mediaOwnerName: JsonRead.text(json['mediaOwnerName']),
      unitId: JsonRead.integer(json['unitId']),
      unitName: JsonRead.text(json['unitName']) ??
          JsonRead.text(json['inventoryName']),
      finalPrice: JsonRead.number(json['finalPrice']) ??
          JsonRead.number(json['quotedPrice']),
      currency: JsonRead.text(json['currency']),
      cycleType: JsonRead.text(json['cycleType']),
      unit: UnitSummary.tryParse(json['unit']),
      cycles: JsonRead.integer(json['cycles']),
    );
  }

  UnitSummary get summary =>
      unit ??
      UnitSummary.basic(
          id: unitId,
          code: unitName,
          mediaOwnerName: mediaOwnerName,
          currency: currency);

  String? get ownerName => mediaOwnerName ?? unit?.mediaOwnerName;

  String? get priceCurrency => currency ?? unit?.currency;

  String? get effectiveCycleType => cycleType ?? unit?.cycleType;
}

class InquiryRepository {
  final InquiryApiService _apiService;

  InquiryRepository(this._apiService);

  // Rečnici za brif (ciljani gradovi i tipovi medija), učitani jednom.
  Map<int, String>? _cityNames;
  Map<int, String>? _unitTypeNames;

  Future<List<Inquiry>> getInquiries(Role role) async {
    final dtos = switch (role) {
      Role.admin => await _apiService.getAdminInquiries(),
      Role.brand => await _apiService.getBrandInquiries(),
      Role.agency => await _apiService.getAgencyInquiries(),
      Role.mediaOwner => await _apiService.getMediaOwnerInquiries(),
    };
    await _loadBriefDictionaries(dtos);
    return dtos.map(_toEntity).toList();
  }

  Future<Inquiry> getInquiryById(int id, Role role) async {
    final dto = switch (role) {
      Role.admin => await _apiService.getAdminInquiryById(id),
      Role.brand => await _apiService.getBrandInquiryById(id),
      Role.agency => await _apiService.getAgencyInquiryById(id),
      Role.mediaOwner => await _apiService.getMediaOwnerInquiryById(id),
    };
    await _loadBriefDictionaries([dto]);
    return _toEntity(dto);
  }

  Inquiry _toEntity(InquiryDto dto) => InquiryMapper.fromDto(
        dto,
        cityNames: _cityNames ?? const {},
        mediaTypeNames: _unitTypeNames ?? const {},
      );

  /// Brif čuva gradove i tipove medija kao ID-jeve; nazivi se učitavaju samo
  /// kada su potrebni. Greška rečnika ne sme da obori listu upita.
  Future<void> _loadBriefDictionaries(List<InquiryDto> dtos) async {
    bool numeric(String? raw) =>
        raw != null &&
        raw.split(',').any((t) => int.tryParse(t.trim()) != null);
    if (_cityNames == null && dtos.any((d) => numeric(d.targetCities))) {
      try {
        _cityNames = await _apiService.getCityNames();
      } catch (_) {}
    }
    if (_unitTypeNames == null &&
        dtos.any((d) => numeric(d.preferredMediaTypes))) {
      try {
        _unitTypeNames = await _apiService.getUnitTypeNames();
      } catch (_) {}
    }
  }

  Future<void> updateAdminNotes(int id, String notes) async {
    await _apiService.updateAdminNotes(id, notes);
  }

  Future<void> updateQuotedPrice(
      int inquiryId, int itemId, double price) async {
    await _apiService.updateQuotedPrice(inquiryId, itemId, price);
  }

  /// PDF upita ili objedinjene ponude sa adrese koja pripada ulozi: brend i
  /// agencija dobijaju svoj (proveren) PDF, stručnjak administratorski.
  Future<List<int>?> downloadPdf(int id, {Role role = Role.admin}) async {
    final response = switch (role) {
      Role.admin => await _apiService.downloadPdf(id),
      Role.brand => await _apiService.downloadBrandPdf(id),
      Role.agency => await _apiService.downloadAgencyPdf(id),
      Role.mediaOwner =>
        throw UnsupportedError('PDF upita nije dostupan vlasniku medija'),
    };
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

  /// Sve površine iz javnog inventara, za dodelu upitu sa brifom.
  Future<List<UnitSummary>> getAssignableUnits() async {
    final data = await _apiService.getPublicUnits();
    return data
        .map(UnitSummary.fromInventoryJson)
        .where((u) => u.id != null)
        .toList();
  }

  /// Jedna površina iz javnog inventara (prikaz izabranih površina u upitu).
  Future<UnitSummary> getUnit(int id) async {
    final data = await _apiService.getPublicUnit(id);
    return UnitSummary.fromInventoryJson(data);
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

  Future<void> updateQuoteItem(
      int quoteId, int itemId, Map<String, dynamic> data) async {
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
