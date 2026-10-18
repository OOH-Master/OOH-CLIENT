class NotificationDto {
  final int id;
  final String? title;
  final String? message;
  final String? type;
  final bool read;
  final String? createdAt;
  final String? relatedEntityType;
  final int? relatedEntityId;

  const NotificationDto({
    required this.id,
    this.title,
    this.message,
    this.type,
    this.read = false,
    this.createdAt,
    this.relatedEntityType,
    this.relatedEntityId,
  });

  /// Server šalje `read` (Jackson skida "is" sa `isRead`), a poruka preko
  /// WebSocket-a može da nosi i `isRead`; prihvataju se oba oblika.
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: _int(json['id']) ?? 0,
      title: json['title']?.toString(),
      message: json['message']?.toString(),
      type: json['type']?.toString(),
      read: _bool(json['read']) ?? _bool(json['isRead']) ?? false,
      createdAt: _dateTime(json['createdAt']),
      relatedEntityType: json['relatedEntityType']?.toString(),
      relatedEntityId: _int(json['relatedEntityId']),
    );
  }

  NotificationDto copyWith({bool? read}) => NotificationDto(
        id: id,
        title: title,
        message: message,
        type: type,
        read: read ?? this.read,
        createdAt: createdAt,
        relatedEntityType: relatedEntityType,
        relatedEntityId: relatedEntityId,
      );

  DateTime? get createdAtDate =>
      createdAt == null ? null : DateTime.tryParse(createdAt!);

  /// Upit na koji se obaveštenje odnosi (sva obaveštenja servera su vezana za upit).
  int? get inquiryId => (relatedEntityType ?? '').toUpperCase() == 'INQUIRY'
      ? relatedEntityId
      : null;

  /// Kratko relativno vreme: "upravo", "pre 5 min", "pre 3 h", "pre 2 dana".
  String get timeAgo {
    final date = createdAtDate;
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'upravo';
    if (diff.inMinutes < 60) return 'pre ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'pre ${diff.inHours} h';
    final days = diff.inDays;
    if (days == 1) return 'juče';
    if (days < 7) return 'pre $days ${_daysWord(days)}';
    return '${date.day}.${date.month}.${date.year}.';
  }

  static String _daysWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'dan';
    return 'dana';
  }

  static int? _int(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  static bool? _bool(dynamic v) {
    if (v is bool) return v;
    if (v is String) return v.toLowerCase() == 'true';
    return null;
  }

  /// LocalDateTime stiže kao ISO tekst, a bez podešenog Jacksona i kao niz
  /// [godina, mesec, dan, sat, minut, sekunda].
  static String? _dateTime(dynamic v) {
    if (v == null) return null;
    if (v is String) return v;
    if (v is List && v.length >= 3) {
      final p =
          v.map((e) => e is num ? e.toInt() : int.tryParse('$e') ?? 0).toList();
      return DateTime(p[0], p[1], p[2], p.length > 3 ? p[3] : 0,
              p.length > 4 ? p[4] : 0, p.length > 5 ? p[5] : 0)
          .toIso8601String();
    }
    return v.toString();
  }
}
