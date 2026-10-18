import 'package:flutter/material.dart';

import '../../../../core/utils/sr_labels.dart';
import '../../../../core/widgets/ui/ui.dart';
import '../../data/dto/campaign_dto.dart';

/// Status kampanje na srpskom: siva za nacrt, ljubičasta dok traju pregovori,
/// indigo za zakupljenu, zelena dok je kampanja u toku, crvena za otkazanu.
class CampaignStatusBadge extends StatelessWidget {
  final CampaignStatus status;

  /// Vrednost iz API-ja ("CANCELLED" nema svoj enum u aplikaciji, pa se
  /// prikazuje preko nje kada postoji).
  final String? raw;
  final bool dense;

  const CampaignStatusBadge({
    super.key,
    required this.status,
    this.raw,
    this.dense = false,
  });

  static String apiValue(CampaignStatus status) => switch (status) {
        CampaignStatus.draft => 'DRAFT',
        CampaignStatus.inNegotiation => 'IN_NEGOTIATION',
        CampaignStatus.booked => 'BOOKED',
        CampaignStatus.running => 'RUNNING',
        CampaignStatus.finished => 'FINISHED',
      };

  static PillTone toneFor(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'IN_NEGOTIATION':
        return PillTone.violet;
      case 'BOOKED':
        return PillTone.primary;
      case 'RUNNING':
        return PillTone.success;
      case 'FINISHED':
        return PillTone.info;
      case 'CANCELLED':
        return PillTone.danger;
      default:
        return PillTone.neutral;
    }
  }

  static String labelFor(String? raw) {
    final label = SrLabels.campaignStatus(raw);
    return label.isEmpty ? SrLabels.campaignStatus('DRAFT') : label;
  }

  @override
  Widget build(BuildContext context) {
    final value = (raw != null && raw!.isNotEmpty) ? raw! : apiValue(status);
    return StatusPill(
      label: labelFor(value),
      tone: toneFor(value),
      dense: dense,
    );
  }
}
