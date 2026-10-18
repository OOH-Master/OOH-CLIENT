import '../../../../core/utils/sr_labels.dart';
import '../../../inquiry/domain/entities/inquiry.dart';

/// Čitanje JSON-a bez pucanja na neočekivan oblik (broj kao tekst, datum kao
/// niz, Spring `Page` umesto liste).
class JsonRead {
  JsonRead._();

  static int? toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v) ?? double.tryParse(v)?.toInt();
    return null;
  }

  static double? toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  static String? str(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

  /// LocalDate/LocalDateTime: ISO tekst ili niz [godina, mesec, dan, ...].
  static String? date(dynamic v) {
    if (v == null) return null;
    if (v is String) return v.isEmpty ? null : v;
    if (v is List && v.length >= 3) {
      final p = v.map((e) => toInt(e) ?? 0).toList();
      return DateTime(p[0], p[1], p[2], p.length > 3 ? p[3] : 0,
              p.length > 4 ? p[4] : 0, p.length > 5 ? p[5] : 0)
          .toIso8601String();
    }
    return v.toString();
  }

  static Map<String, dynamic> map(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return <String, dynamic>{};
  }

  /// Lista objekata iz liste ili iz `content` Spring stranice.
  static List<Map<String, dynamic>> list(dynamic v) {
    final raw = v is List
        ? v
        : (v is Map && v['content'] is List ? v['content'] as List : const []);
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }

  /// Mapa naziv → broj (npr. `inquiriesByStatus`).
  static Map<String, int> counts(dynamic v) {
    final result = <String, int>{};
    if (v is Map) {
      v.forEach((key, value) {
        final n = toInt(value);
        if (key != null && n != null) result[key.toString()] = n;
      });
    }
    return result;
  }

  /// Mapa valuta → iznos (npr. `totalsByCurrency`).
  static Map<String, double> amounts(dynamic v) {
    final result = <String, double>{};
    if (v is Map) {
      v.forEach((key, value) {
        final n = toDouble(value);
        final k = key?.toString().trim().toUpperCase() ?? '';
        if (k.isNotEmpty && n != null) result[k] = n;
      });
    }
    return result;
  }
}

/// Zbir iznosa po valutama; različite valute se nikad ne sabiraju.
class CurrencySum {
  final Map<String, double> _totals = {};

  void add(String? currency, double? amount) {
    if (amount == null) return;
    final key = (currency ?? '').trim().toUpperCase();
    _totals[key.isEmpty ? 'EUR' : key] =
        (_totals[key.isEmpty ? 'EUR' : key] ?? 0) + amount;
  }

  void addAll(Map<String, double> totals) =>
      totals.forEach((currency, amount) => add(currency, amount));

  /// Najveći iznos prvi (on ide u glavnu vrednost KPI pločice).
  Map<String, double> get totals {
    final entries = _totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return {for (final e in entries) e.key: e.value};
  }

  bool get isEmpty => _totals.isEmpty;
}

InquiryStatus? inquiryStatusFromApi(String? raw) {
  final v = (raw ?? '').trim().toUpperCase();
  for (final s in InquiryStatus.values) {
    if (s.apiValue == v) return s;
  }
  return null;
}

/// Broj upita po statusu, u redosledu toka upita.
Map<InquiryStatus, int> statusCounts(Map<String, int> raw) {
  final result = <InquiryStatus, int>{};
  raw.forEach((key, value) {
    final s = inquiryStatusFromApi(key);
    if (s != null) result[s] = (result[s] ?? 0) + value;
  });
  return {
    for (final s in InquiryStatus.values)
      if (result.containsKey(s)) s: result[s]!,
  };
}

Map<InquiryStatus, int> statusCountsOf(Iterable<Inquiry> inquiries) {
  final result = <InquiryStatus, int>{};
  for (final i in inquiries) {
    result[i.status] = (result[i.status] ?? 0) + 1;
  }
  return {
    for (final s in InquiryStatus.values)
      if (result.containsKey(s)) s: result[s]!,
  };
}

/// Upit je aktivan dok ne dobije konačan ishod.
bool isActiveInquiry(InquiryStatus s) =>
    s != InquiryStatus.acceptedByClient &&
    s != InquiryStatus.rejectedByClient &&
    s != InquiryStatus.realized &&
    s != InquiryStatus.closed;

bool isAcceptedInquiry(InquiryStatus? s) =>
    s == InquiryStatus.acceptedByClient || s == InquiryStatus.realized;

class MonthCount {
  final DateTime month;
  final int count;

  const MonthCount(this.month, this.count);
}

/// Analitika kontrolne table, iz odgovora za bilo koju ulogu (polja koja
/// uloga ne dobija ostaju prazna).
class DashboardAnalytics {
  final bool failed;
  final Map<InquiryStatus, int> inquiriesByStatus;
  final Map<String, int> usersByRole;
  final Map<String, int> inventoryByCity;
  final Map<String, int> inquiriesPerBrand;
  final List<MonthCount> monthlyTrend;
  final double? totalSpend;
  final int? inventoryCount;
  final int? totalQuotes;
  final int? totalInventory;
  final double? conversionRate;
  final double? averageBudget;

  const DashboardAnalytics({
    this.failed = false,
    this.inquiriesByStatus = const {},
    this.usersByRole = const {},
    this.inventoryByCity = const {},
    this.inquiriesPerBrand = const {},
    this.monthlyTrend = const [],
    this.totalSpend,
    this.inventoryCount,
    this.totalQuotes,
    this.totalInventory,
    this.conversionRate,
    this.averageBudget,
  });

  static const empty = DashboardAnalytics();

  factory DashboardAnalytics.fromMap(Map<String, dynamic> data) {
    final inquiryAnalytics = JsonRead.map(data['inquiryAnalytics']);
    final inventoryAnalytics = JsonRead.map(data['inventoryAnalytics']);

    // Admin: inquiriesByStatus (pregled) ili countByStatus (analitika upita).
    var byStatus = JsonRead.counts(data['inquiriesByStatus']);
    if (byStatus.isEmpty) {
      byStatus = JsonRead.counts(inquiryAnalytics['countByStatus']);
    }

    final byType = JsonRead.counts(data['inventoryByType']);
    final totalInventory =
        JsonRead.toInt(inventoryAnalytics['totalInventory']) ??
            (byType.isEmpty
                ? null
                : byType.values.fold<int>(0, (a, b) => a + b));

    return DashboardAnalytics(
      failed: data['error'] != null,
      inquiriesByStatus: statusCounts(byStatus),
      usersByRole: JsonRead.counts(data['usersByRole']),
      inventoryByCity: JsonRead.counts(inventoryAnalytics['countByCity']),
      inquiriesPerBrand: JsonRead.counts(data['inquiriesPerBrand']),
      monthlyTrend: _months(data['monthlyInquiryTrend']),
      totalSpend: JsonRead.toDouble(data['totalSpend']),
      inventoryCount: JsonRead.toInt(data['inventoryCount']),
      totalQuotes: JsonRead.toInt(data['totalQuotes']),
      totalInventory: totalInventory,
      conversionRate: JsonRead.toDouble(inquiryAnalytics['conversionRate']),
      averageBudget: JsonRead.toDouble(inquiryAnalytics['averageBudget']),
    );
  }

  int get totalInquiries =>
      inquiriesByStatus.values.fold<int>(0, (a, b) => a + b);

  int get totalUsers => usersByRole.values.fold<int>(0, (a, b) => a + b);

  /// Upiti po mesecima ("2026-03" → broj), sa popunjenim mesecima bez upita;
  /// najmanje šest, najviše dvanaest meseci do tekućeg.
  static List<MonthCount> _months(dynamic raw) {
    final byMonth = <DateTime, int>{};
    for (final row in JsonRead.list(raw)) {
      final key = JsonRead.str(row['month']);
      final count = JsonRead.toInt(row['count']) ?? 0;
      if (key == null) continue;
      final parts = key.split('-');
      if (parts.length < 2) continue;
      final y = int.tryParse(parts[0]);
      final m = int.tryParse(parts[1]);
      if (y == null || m == null) continue;
      final month = DateTime(y, m);
      byMonth[month] = (byMonth[month] ?? 0) + count;
    }
    return fillMonths(byMonth);
  }
}

/// Upiti po mesecima iz datuma kreiranja (kada analitika nije stigla).
List<MonthCount> monthlyCountsOf(Iterable<Inquiry> inquiries) {
  final byMonth = <DateTime, int>{};
  for (final i in inquiries) {
    final d = i.createdAt == null ? null : DateTime.tryParse(i.createdAt!);
    if (d == null) continue;
    final month = DateTime(d.year, d.month);
    byMonth[month] = (byMonth[month] ?? 0) + 1;
  }
  return fillMonths(byMonth);
}

/// Neprekidan niz meseci do tekućeg (najmanje šest, najviše dvanaest), sa
/// nulom za mesece bez upita.
List<MonthCount> fillMonths(Map<DateTime, int> byMonth) {
  if (byMonth.isEmpty) return const [];
  final now = DateTime.now();
  var end = DateTime(now.year, now.month);
  final lastData = byMonth.keys.reduce((a, b) => a.isAfter(b) ? a : b);
  if (lastData.isAfter(end)) end = lastData;
  final firstData = byMonth.keys.reduce((a, b) => a.isBefore(b) ? a : b);
  var start = DateTime(end.year, end.month - 5);
  if (firstData.isBefore(start)) start = firstData;
  final earliest = DateTime(end.year, end.month - 11);
  if (start.isBefore(earliest)) start = earliest;

  final result = <MonthCount>[];
  var cursor = start;
  while (!cursor.isAfter(end)) {
    result.add(MonthCount(cursor, byMonth[cursor] ?? 0));
    cursor = DateTime(cursor.year, cursor.month + 1);
  }
  return result;
}

/// Jedna površina u zahtevu za ponudu vlasnika medija.
class QuoteUnitLine {
  final int? unitId;
  final String? code;
  final String? siteName;
  final String? address;
  final String? city;
  final String? country;
  final String? unitType;
  final String? mediaFormat;
  final String? imageUrl;
  final double? price;
  final double? listPrice;
  final String? currency;
  final String? cycleType;
  final double? pricePerCycle;
  final double? width;
  final double? height;
  final String? sizeUnit;

  const QuoteUnitLine({
    this.unitId,
    this.code,
    this.siteName,
    this.address,
    this.city,
    this.country,
    this.unitType,
    this.mediaFormat,
    this.imageUrl,
    this.price,
    this.listPrice,
    this.currency,
    this.cycleType,
    this.pricePerCycle,
    this.width,
    this.height,
    this.sizeUnit,
  });

  factory QuoteUnitLine.fromJson(Map<String, dynamic> json) {
    final unit = JsonRead.map(json['unit']);
    return QuoteUnitLine(
      unitId: JsonRead.toInt(json['unitId']) ?? JsonRead.toInt(unit['id']),
      code: JsonRead.str(unit['code']) ?? JsonRead.str(json['unitName']),
      siteName: JsonRead.str(unit['siteName']),
      address: JsonRead.str(unit['address']),
      city: JsonRead.str(unit['city']),
      country: JsonRead.str(unit['country']),
      unitType: JsonRead.str(unit['unitType']),
      mediaFormat: JsonRead.str(unit['mediaFormat']),
      imageUrl: JsonRead.str(unit['imageUrl']),
      price: JsonRead.toDouble(json['price']),
      listPrice: JsonRead.toDouble(json['listPrice']),
      currency:
          JsonRead.str(json['currency']) ?? JsonRead.str(unit['currency']),
      cycleType:
          JsonRead.str(unit['cycleType']) ?? JsonRead.str(json['cycleType']),
      pricePerCycle: JsonRead.toDouble(unit['pricePerCycle']),
      width: JsonRead.toDouble(unit['physicalWidth']),
      height: JsonRead.toDouble(unit['physicalHeight']),
      sizeUnit: JsonRead.str(unit['sizeUnit']),
    );
  }

  bool get digital => SrLabels.isDigital(unitType);

  /// Naziv lokacije; šifra je poslednja opcija, a "Površina #id" krajnja.
  String get title =>
      siteName ??
      address ??
      code ??
      (unitId != null ? 'Površina #$unitId' : 'Površina');

  String get place => SrLabels.place(city, country);
}

/// Zahtev za ponudu vlasnika medija (OwnerQuoteDto) sa kontekstom upita.
class OwnerQuoteSummary {
  final int id;
  final int inquiryId;
  final String status;
  final InquiryStatus? inquiryStatus;
  final String? inquiryType;
  final String? startDate;
  final String? endDate;
  final String? requesterType;
  final String? requesterName;
  final String? contactName;
  final String? createdAt;
  final Map<String, double> totalsByCurrency;
  final List<QuoteUnitLine> items;

  const OwnerQuoteSummary({
    required this.id,
    required this.inquiryId,
    required this.status,
    this.inquiryStatus,
    this.inquiryType,
    this.startDate,
    this.endDate,
    this.requesterType,
    this.requesterName,
    this.contactName,
    this.createdAt,
    this.totalsByCurrency = const {},
    this.items = const [],
  });

  factory OwnerQuoteSummary.fromJson(Map<String, dynamic> json) {
    return OwnerQuoteSummary(
      id: JsonRead.toInt(json['id']) ?? 0,
      inquiryId: JsonRead.toInt(json['inquiryId']) ?? 0,
      status: (JsonRead.str(json['status']) ?? 'NEW').toUpperCase(),
      inquiryStatus: inquiryStatusFromApi(JsonRead.str(json['inquiryStatus'])),
      inquiryType: JsonRead.str(json['inquiryType']),
      startDate: JsonRead.date(json['startDate']),
      endDate: JsonRead.date(json['endDate']),
      requesterType: JsonRead.str(json['requesterType']),
      requesterName: JsonRead.str(json['requesterName']),
      contactName: JsonRead.str(json['contactName']),
      createdAt: JsonRead.date(json['createdAt']),
      totalsByCurrency: JsonRead.amounts(json['totalsByCurrency']),
      items: JsonRead.list(json['items']).map(QuoteUnitLine.fromJson).toList(),
    );
  }

  bool get isOpen => status == 'NEW' || status == 'IN_PROGRESS';

  bool get isAccepted =>
      status != 'DECLINED' && isAcceptedInquiry(inquiryStatus);

  DateTime? get created =>
      createdAt == null ? null : DateTime.tryParse(createdAt!);

  /// Zbir po valutama: sa servera, a ako ga nema, iz cena stavki
  /// (predložena cena iz cenovnika dok vlasnik ne unese svoju).
  Map<String, double> get amounts {
    if (totalsByCurrency.isNotEmpty) return totalsByCurrency;
    final sum = CurrencySum();
    for (final item in items) {
      sum.add(item.currency, item.price ?? item.listPrice);
    }
    return sum.totals;
  }

  String get requesterLabel =>
      requesterName ??
      contactName ??
      (requesterType == null
          ? 'Klijent'
          : SrLabels.requesterType(requesterType));

  /// Gradovi površina u zahtevu: "Beograd, Novi Sad".
  String get cities {
    final names = <String>[];
    for (final item in items) {
      final c = SrLabels.city(item.city);
      if (c.isNotEmpty && !names.contains(c)) names.add(c);
    }
    return names.join(', ');
  }
}

/// Zbir objedinjene ponude po valutama (`totalsByCurrency`, a bez njega iz stavki).
Map<String, double> offerTotals(Map<String, dynamic> offer) {
  final fromServer = JsonRead.amounts(offer['totalsByCurrency']);
  if (fromServer.isNotEmpty) return fromServer;
  final sum = CurrencySum();
  final fallbackCurrency = JsonRead.str(offer['currency']);
  for (final item in JsonRead.list(offer['items'])) {
    final unit = JsonRead.map(item['unit']);
    sum.add(
      JsonRead.str(item['currency']) ??
          JsonRead.str(unit['currency']) ??
          fallbackCurrency,
      JsonRead.toDouble(item['finalPrice']),
    );
  }
  return sum.totals;
}
