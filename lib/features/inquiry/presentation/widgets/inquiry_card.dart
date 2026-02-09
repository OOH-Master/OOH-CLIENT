import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/inquiry.dart';
import 'inquiry_status_badge.dart';

class InquiryCard extends StatelessWidget {
  final Inquiry inquiry;
  final VoidCallback onTap;

  const InquiryCard({
    super.key,
    required this.inquiry,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    inquiry.contactName ?? 'Inquiry #${inquiry.id}',
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),
                InquiryStatusBadge(status: inquiry.status),
              ],
            ),
            const SizedBox(height: 8),
            if (inquiry.contactEmail != null)
              Text(
                inquiry.contactEmail!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                if (inquiry.startDate != null) ...[
                  Icon(Icons.calendar_today, size: 14, color: AppColors.mutedForeground),
                  const SizedBox(width: 4),
                  Text(
                    '${inquiry.startDate} — ${inquiry.endDate ?? '?'}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
                const Spacer(),
                if (inquiry.items.isNotEmpty)
                  Text(
                    '${inquiry.items.length} items',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
              ],
            ),
            if (inquiry.budget != null) ...[
              const SizedBox(height: 4),
              Text(
                'Budget: €${inquiry.budget!.toStringAsFixed(0)}',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
