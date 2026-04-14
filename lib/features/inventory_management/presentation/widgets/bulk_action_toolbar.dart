import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class BulkActionToolbar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onActivateAll;
  final VoidCallback onDeactivateAll;
  final VoidCallback onDeleteAll;
  final VoidCallback onClearSelection;

  const BulkActionToolbar({
    super.key,
    required this.selectedCount,
    required this.onActivateAll,
    required this.onDeactivateAll,
    required this.onDeleteAll,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.check_circle, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            '$selectedCount odabrano',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          _buildActionButton(
            icon: Icons.check_circle_outline,
            label: 'Aktiviraj',
            color: AppColors.success,
            onTap: onActivateAll,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.pause_circle_outline,
            label: 'Deaktiviraj',
            color: AppColors.warning,
            onTap: onDeactivateAll,
          ),
          const SizedBox(width: 8),
          _buildActionButton(
            icon: Icons.delete_outline,
            label: 'Obrisi',
            color: AppColors.destructive,
            onTap: onDeleteAll,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(Icons.close, size: 18, color: AppColors.mutedForeground),
            onPressed: onClearSelection,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            tooltip: 'Ponisti selekciju',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return TextButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 16, color: color),
      label: Text(
        label,
        style: AppTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
