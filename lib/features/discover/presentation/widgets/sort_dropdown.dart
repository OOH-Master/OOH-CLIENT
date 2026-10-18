import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/discover_bloc.dart';

/// Izbor redosleda rezultata.
class SortDropdown extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onChanged;

  /// Uže dugme za telefon.
  final bool compact;

  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onChanged,
    this.compact = false,
  });

  static String labelFor(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'Najnovije';
      case SortOption.priceAsc:
        return 'Cena: od najniže';
      case SortOption.priceDesc:
        return 'Cena: od najviše';
    }
  }

  /// Kraći naziv za usko dugme na telefonu.
  static String shortLabelFor(SortOption option) {
    switch (option) {
      case SortOption.newest:
        return 'Najnovije';
      case SortOption.priceAsc:
        return 'Najjeftinije';
      case SortOption.priceDesc:
        return 'Najskuplje';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SortOption>(
      tooltip: 'Redosled rezultata',
      initialValue: currentSort,
      onSelected: onChanged,
      position: PopupMenuPosition.under,
      offset: const Offset(0, 6),
      itemBuilder: (context) => [
        for (final option in SortOption.values)
          PopupMenuItem<SortOption>(
            value: option,
            height: 42,
            child: Row(
              children: [
                SizedBox(
                  width: 22,
                  child: option == currentSort
                      ? const Icon(Icons.check_rounded,
                          size: 18, color: AppColors.primary)
                      : null,
                ),
                const SizedBox(width: 6),
                Text(
                  labelFor(option),
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: option == currentSort
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
      ],
      child: Container(
        height: 40,
        padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.input),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              compact ? shortLabelFor(currentSort) : labelFor(currentSort),
              style: AppTypography.labelMedium.copyWith(
                color: AppColors.foreground,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more_rounded,
                size: 18, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
