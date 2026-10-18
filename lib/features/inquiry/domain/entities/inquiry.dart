import '../../../../core/utils/sr_format.dart';
import '../../../../core/utils/sr_labels.dart';
import 'currency_totals.dart';
import 'unit_summary.dart';

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

  /// Upit je još u radu (platforma ili vlasnici medija).
  bool get isActive =>
      this == InquiryStatus.submitted ||
      this == InquiryStatus.inProgress ||
      this == InquiryStatus.quotesRequested ||
      this == InquiryStatus.pricingReady;

  /// Upit je završen: klijent je odlučio ili je upit zatvoren.
  bool get isFinished =>
      this == InquiryStatus.acceptedByClient ||
      this == InquiryStatus.rejectedByClient ||
      this == InquiryStatus.realized ||
      this == InquiryStatus.closed;

  /// Objedinjena ponuda postoji (poslata je klijentu ili je o njoj odlučeno).
  bool get hasOffer =>
      this == InquiryStatus.offerSent ||
      this == InquiryStatus.acceptedByClient ||
      this == InquiryStatus.rejectedByClient ||
      this == InquiryStatus.realized;
}

class InquiryItem {
  final int id;
  final int? inventoryItemId;
  final String? inventoryItemName;
  final String? inventoryItemAddress;
  final String? inventoryItemCity;
  final String? mediaOwnerName;
  final double? quotedPrice;

  /// Sažetak površine (fotografija, šifra, lokacija, format, cenovnik).
  final UnitSummary? unit;

  /// Broj ciklusa zakupa za period upita.
  final int? cycles;

  /// Valuta u kojoj je izražena [quotedPrice].
  final String? currency;

  const InquiryItem({
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

  /// Sažetak površine; kada ga backend ne pošalje, gradi se iz ravnih polja.
  UnitSummary get summary =>
      unit ??
      UnitSummary.basic(
        id: inventoryItemId,
        code: inventoryItemName,
        address: inventoryItemAddress,
        city: inventoryItemCity,
        mediaOwnerName: mediaOwnerName,
        currency: currency,
      );

  String? get priceCurrency => currency ?? unit?.currency;

  String? get ownerName => mediaOwnerName ?? unit?.mediaOwnerName;

  /// "2 × 2 nedelje", "14 dana"
  String get cyclesText => SrFormat.cyclesLabel(cycles, unit?.cycleType);
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

  /// UNIT_SELECTION (izbor površina) ili BRIEF (brif kampanje).
  final String? inquiryType;

  /// Naziv brenda, zatim agencije, a ako ih nema, ime kontakt osobe.
  final String? requesterName;

  /// Ciljani gradovi i tipovi medija iz brifa, kako ih backend čuva (ID-jevi
  /// razdvojeni zarezom), i njihovi nazivi razrešeni iz rečnika.
  final String? targetCities;
  final String? preferredMediaTypes;
  final List<String> targetCityNames;
  final List<String> preferredMediaTypeNames;
  final String? targetAudience;
  final String? additionalRequirements;
  final int itemCount;

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
    this.inquiryType,
    this.requesterName,
    this.targetCities,
    this.preferredMediaTypes,
    this.targetCityNames = const [],
    this.preferredMediaTypeNames = const [],
    this.targetAudience,
    this.additionalRequirements,
    this.itemCount = 0,
  });

  bool get isBrief => (inquiryType ?? '').toUpperCase() == 'BRIEF';

  /// Broj površina: stavke ako su učitane, inače broj sa servera.
  int get unitCount => items.isNotEmpty ? items.length : itemCount;

  int? get days => SrFormat.days(startDate, endDate);

  /// "16.11. – 29.11.2026. (14 dana)"
  String get periodText {
    final period = SrFormat.period(startDate, endDate);
    final d = days;
    return d == null ? period : '$period (${SrFormat.daysLabel(d)})';
  }

  /// Klijent: naziv brenda ili agencije, a ako ga nema, kontakt osoba.
  String? get clientName => requesterName ?? contactName;

  /// Gradovi izabranih površina, bez ponavljanja ("Beograd", "Zagreb").
  List<String> get unitCities {
    final seen = <String>{};
    for (final item in items) {
      final city = SrLabels.city(item.summary.city);
      if (city.isNotEmpty) seen.add(city);
    }
    return seen.toList();
  }

  int get ownerCount => items
      .map((i) => i.ownerName ?? '')
      .where((n) => n.isNotEmpty)
      .toSet()
      .length;

  /// Zbir cena stavki po valuti (procena iz cenovnika ili cena stručnjaka).
  Map<String, double> get itemTotals =>
      CurrencyTotals.sum(items, (i) => i.quotedPrice, (i) => i.priceCurrency);

  DateTime? get createdAtDate => SrFormat.parseDate(createdAt);
}
