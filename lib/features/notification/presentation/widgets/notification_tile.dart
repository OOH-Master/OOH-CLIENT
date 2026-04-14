import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/dto/notification_dto.dart';

class NotificationTile extends StatelessWidget {
  final NotificationDto notification;
  final VoidCallback? onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'INQUIRY':
        return Icons.mail_outline;
      case 'CAMPAIGN':
        return Icons.campaign_outlined;
      case 'INVENTORY':
        return Icons.inventory_2_outlined;
      case 'SYSTEM':
        return Icons.info_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'INQUIRY':
        return AppColors.info;
      case 'CAMPAIGN':
        return AppColors.success;
      case 'INVENTORY':
        return AppColors.warning;
      case 'SYSTEM':
        return AppColors.primary;
      default:
        return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: BoxDecoration(
          color: notification.read ? Colors.white : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: notification.read ? AppColors.border : AppColors.primary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(_icon, size: 18, color: _iconColor),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? '',
                          style: AppTypography.bodySmall.copyWith(
                            fontWeight: notification.read ? FontWeight.w400 : FontWeight.w600,
                            color: AppColors.foreground,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        notification.timeAgo,
                        style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                      ),
                    ],
                  ),
                  if (notification.message != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      notification.message!,
                      style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (!notification.read) ...[
              const SizedBox(width: AppSpacing.xs),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
