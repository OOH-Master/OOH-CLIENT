import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/dto/campaign_dto.dart';

class CampaignStatusBadge extends StatelessWidget {
  final CampaignStatus status;

  const CampaignStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final (Color bg, Color fg, String label) = switch (status) {
      CampaignStatus.draft => (
        AppColors.muted,
        AppColors.mutedForeground,
        l10n.statusDraft,
      ),
      CampaignStatus.inNegotiation => (
        const Color(0xFFFEF3C7),
        const Color(0xFF92400E),
        l10n.statusInNegotiation,
      ),
      CampaignStatus.booked => (
        const Color(0xFFDBEAFE),
        const Color(0xFF1E40AF),
        l10n.statusBooked,
      ),
      CampaignStatus.running => (
        const Color(0xFFD1FAE5),
        const Color(0xFF065F46),
        l10n.statusRunning,
      ),
      CampaignStatus.finished => (
        const Color(0xFFE5E7EB),
        const Color(0xFF374151),
        l10n.statusFinished,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: fg,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
