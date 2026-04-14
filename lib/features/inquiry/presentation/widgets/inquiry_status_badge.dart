import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/inquiry.dart';

class InquiryStatusBadge extends StatelessWidget {
  final InquiryStatus status;

  const InquiryStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        _label(l10n),
        style: AppTypography.caption.copyWith(
          color: _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color get _color {
    switch (status) {
      case InquiryStatus.submitted:
        return AppColors.info;
      case InquiryStatus.inProgress:
        return AppColors.warning;
      case InquiryStatus.quotesRequested:
        return const Color(0xFF8B5CF6); // violet
      case InquiryStatus.pricingReady:
        return AppColors.primary;
      case InquiryStatus.offerSent:
        return const Color(0xFF0EA5E9); // sky blue
      case InquiryStatus.acceptedByClient:
        return AppColors.success;
      case InquiryStatus.rejectedByClient:
        return AppColors.destructive;
      case InquiryStatus.realized:
        return AppColors.success;
      case InquiryStatus.closed:
        return AppColors.mutedForeground;
    }
  }

  String _label(AppLocalizations l10n) {
    switch (status) {
      case InquiryStatus.submitted:
        return l10n.statusSubmitted;
      case InquiryStatus.inProgress:
        return l10n.statusInProgress;
      case InquiryStatus.quotesRequested:
        return 'Quotes Requested';
      case InquiryStatus.pricingReady:
        return l10n.statusPricingReady;
      case InquiryStatus.offerSent:
        return 'Offer Sent';
      case InquiryStatus.acceptedByClient:
        return l10n.statusAccepted;
      case InquiryStatus.rejectedByClient:
        return l10n.statusRejected;
      case InquiryStatus.realized:
        return l10n.statusRealized;
      case InquiryStatus.closed:
        return l10n.statusClosed;
    }
  }
}
