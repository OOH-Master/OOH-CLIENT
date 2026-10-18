import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/ui/ui.dart';

/// Traka alata iznad liste površina: pretraga, status (Sve/Aktivne/Neaktivne)
/// sa brojem površina i redosled.
class InventoryFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? activeStatusFilter;
  final String currentSort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String> onSortChanged;

  /// Broj površina po statusu; ključ `null` je ukupan broj.
  final Map<String?, int> counts;

  const InventoryFilterBar({
    super.key,
    required this.searchController,
    required this.activeStatusFilter,
    required this.currentSort,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onSortChanged,
    this.counts = const {},
  });

  static const _sortLabels = {
    'name': 'Naziv',
    'date': 'Najnovije',
    'price': 'Cena',
  };

  @override
  Widget build(BuildContext context) {
    final search = TextField(
      controller: searchController,
      onChanged: onSearchChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        isDense: true,
        hintText: 'Pretraži po nazivu, adresi ili opisu',
        prefixIcon: const Icon(Icons.search_rounded, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        suffixIcon: searchController.text.isNotEmpty
            ? IconButton(
                tooltip: 'Obriši pretragu',
                icon: const Icon(Icons.close_rounded, size: 18),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              )
            : null,
      ),
    );

    final segments = _StatusSegments(
      value: activeStatusFilter,
      counts: counts,
      onChanged: onStatusFilterChanged,
    );

    final sort = _SortButton(
      label: _sortLabels[currentSort] ?? currentSort,
      onSelected: onSortChanged,
      labels: _sortLabels,
    );

    return DecoratedBox(
      decoration: AppDecorations.card(),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth >= 760) {
              return Row(
                children: [
                  Expanded(child: search),
                  const SizedBox(width: 12),
                  segments,
                  const SizedBox(width: 12),
                  sort,
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                search,
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: segments,
                      ),
                    ),
                    const SizedBox(width: 8),
                    sort,
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusSegments extends StatelessWidget {
  final String? value;
  final Map<String?, int> counts;
  final ValueChanged<String?> onChanged;

  const _StatusSegments(
      {required this.value, required this.counts, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    const options = <(String?, String)>[
      (null, 'Sve'),
      ('ACTIVE', 'Aktivne'),
      ('DISABLED', 'Neaktivne'),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final (key, label) in options)
            _Segment(
              label: label,
              count: counts[key],
              selected: value == key,
              onTap: () => onChanged(key),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String label;
  final int? count;
  final bool selected;
  final VoidCallback onTap;

  const _Segment({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: AppTypography.labelMedium.copyWith(
                  color: selected ? AppColors.foreground : AppColors.text2,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (count != null) ...[
                const SizedBox(width: 6),
                Text(
                  '$count',
                  style: AppTypography.labelSmall.copyWith(
                    color: selected
                        ? AppColors.primary
                        : AppColors.mutedForeground,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  final String label;
  final Map<String, String> labels;
  final ValueChanged<String> onSelected;

  const _SortButton(
      {required this.label, required this.labels, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      tooltip: 'Redosled',
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final e in labels.entries)
          PopupMenuItem(value: e.key, child: Text(e.value)),
      ],
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.input),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.swap_vert_rounded,
                size: 18, color: AppColors.mutedForeground),
            const SizedBox(width: 6),
            Text(label,
                style: AppTypography.labelMedium
                    .copyWith(color: AppColors.foreground)),
            const SizedBox(width: 2),
            const Icon(Icons.expand_more_rounded,
                size: 18, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
