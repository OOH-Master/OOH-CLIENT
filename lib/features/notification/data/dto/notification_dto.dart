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

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as int,
      title: json['title'] as String?,
      message: json['message'] as String?,
      type: json['type'] as String?,
      read: json['read'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
      relatedEntityType: json['relatedEntityType'] as String?,
      relatedEntityId: json['relatedEntityId'] as int?,
    );
  }

  String get timeAgo {
    if (createdAt == null) return '';
    try {
      final date = DateTime.parse(createdAt!);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'upravo';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min';
      if (diff.inHours < 24) return '${diff.inHours}h';
      if (diff.inDays < 7) return '${diff.inDays}d';
      return '${(diff.inDays / 7).floor()}w';
    } catch (_) {
      return '';
    }
  }
}
