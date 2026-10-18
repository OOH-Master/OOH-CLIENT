import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';

/// Traka grupnih akcija; pojavljuje se kada je izabrana bar jedna površina.
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
    final buttonStyle = OutlinedButton.styleFrom(
      minimumSize: const Size(0, 38),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      textStyle:
          AppTypography.labelMedium.copyWith(fontWeight: FontWeight.w600),
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: onActivateAll,
          style: buttonStyle,
          icon: const Icon(Icons.play_circle_outline_rounded, size: 17),
          label: const Text('Aktiviraj'),
        ),
        OutlinedButton.icon(
          onPressed: onDeactivateAll,
          style: buttonStyle,
          icon: const Icon(Icons.pause_circle_outline_rounded, size: 17),
          label: const Text('Deaktiviraj'),
        ),
        OutlinedButton.icon(
          onPressed: onDeleteAll,
          style: buttonStyle.copyWith(
            foregroundColor:
                const WidgetStatePropertyAll(AppColors.destructive),
            side: WidgetStatePropertyAll(
              BorderSide(color: AppColors.destructive.withValues(alpha: 0.35)),
            ),
          ),
          icon: const Icon(Icons.delete_outline_rounded, size: 17),
          label: const Text('Obriši'),
        ),
      ],
    );

    final count = Text(
      SrFormat.count(selectedCount, 'izabrana površina', 'izabrane površine',
          'izabranih površina'),
      style: AppTypography.labelLarge.copyWith(color: AppColors.primaryStrong),
    );

    final close = IconButton(
      tooltip: 'Poništi izbor',
      icon: const Icon(Icons.close_rounded, size: 20),
      onPressed: onClearSelection,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 8, 6, 8),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 640) {
            return Row(
              children: [
                count,
                const Spacer(),
                actions,
                const SizedBox(width: 4),
                close,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Expanded(child: count), close]),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, right: 8),
                child: actions,
              ),
            ],
          );
        },
      ),
    );
  }
}
