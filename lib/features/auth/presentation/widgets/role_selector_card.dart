import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/role.dart';

class RoleSelectorCard extends StatelessWidget {
  final Role role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleSelectorCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  IconData get _icon {
    switch (role) {
      case Role.brand:
        return Icons.storefront_outlined;
      case Role.agency:
        return Icons.business_center_outlined;
      case Role.mediaOwner:
        return Icons.tv_outlined;
      case Role.admin:
        return Icons.admin_panel_settings_outlined;
    }
  }

  String get _title {
    switch (role) {
      case Role.brand:
        return 'Brend';
      case Role.agency:
        return 'Agencija';
      case Role.mediaOwner:
        return 'Vlasnik medija';
      case Role.admin:
        return 'Admin';
    }
  }

  String get _description {
    switch (role) {
      case Role.brand:
        return 'Oglasavac koji trazi reklamni prostor za svoje kampanje.';
      case Role.agency:
        return 'Agencija koja upravlja kampanjama za vise brendova.';
      case Role.mediaOwner:
        return 'Vlasnik oglasnog inventara (bilbordi, citylight-ovi, ekrani).';
      case Role.admin:
        return 'Administrator sistema.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondary : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : AppColors.muted,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(
                _icon,
                size: 28,
                color: isSelected ? AppColors.primary : AppColors.mutedForeground,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              _title,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.foreground,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              _description,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.mutedForeground,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.xs),
              Icon(Icons.check_circle, color: AppColors.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
