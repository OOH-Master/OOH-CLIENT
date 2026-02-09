class CampaignDto {
  final int id;
  final String? name;
  final String? description;
  final String? startDate;
  final String? endDate;
  final double? budget;
  final String? status;
  final String? brandUsername;
  final String? createdAt;

  const CampaignDto({
    required this.id,
    this.name,
    this.description,
    this.startDate,
    this.endDate,
    this.budget,
    this.status,
    this.brandUsername,
    this.createdAt,
  });

  factory CampaignDto.fromJson(Map<String, dynamic> json) {
    return CampaignDto(
      id: json['id'] as int,
      name: json['name'] as String?,
      description: json['description'] as String?,
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      budget: (json['budget'] as num?)?.toDouble(),
      status: json['status'] as String?,
      brandUsername: json['brandUsername'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}

enum CampaignStatus {
  draft,
  inNegotiation,
  booked,
  running,
  finished;

  static CampaignStatus fromApi(String? value) {
    switch (value) {
      case 'DRAFT':
        return CampaignStatus.draft;
      case 'IN_NEGOTIATION':
        return CampaignStatus.inNegotiation;
      case 'BOOKED':
        return CampaignStatus.booked;
      case 'RUNNING':
        return CampaignStatus.running;
      case 'FINISHED':
        return CampaignStatus.finished;
      default:
        return CampaignStatus.draft;
    }
  }
}
