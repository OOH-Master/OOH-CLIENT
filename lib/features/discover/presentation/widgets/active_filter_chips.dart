import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/sr_format.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';
import 'unit_labels.dart';

/// Aktivni filteri kao oznake koje se uklanjaju jednim klikom, i "Obriši sve".
class ActiveFilterChips extends StatelessWidget {
  final InventoryFilterParams filters;
  final List<DictionaryRefDto> unitTypes;
  final List<DictionaryRefDto> mediaFormats;
  final List<DictionaryRefDto> venueTypes;
  final void Function(InventoryFilterParams updatedFilters) onFilterRemoved;
  final VoidCallback onClearAll;
  final EdgeInsetsGeometry padding;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    this.unitTypes = const [],
    this.mediaFormats = const [],
    this.venueTypes = const [],
    required this.onFilterRemoved,
    required this.onClearAll,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final chips = <_FilterChipData>[];

    if (filters.unitTypeId != null) {
      final name = DiscoverLabels.dictionaryLabel(
              unitTypes, filters.unitTypeId, DiscoverLabels.unitType) ??
          'izabran';
      chips.add(_FilterChipData(
        label: 'Tip: $name',
        onRemove: () =>
            onFilterRemoved(filters.copyWith(clearUnitTypeId: true)),
      ));
    }

    if (filters.mediaFormatId != null) {
      final name = DiscoverLabels.dictionaryLabel(
              mediaFormats, filters.mediaFormatId, DiscoverLabels.format) ??
          'izabran';
      chips.add(_FilterChipData(
        label: 'Format: $name',
        onRemove: () =>
            onFilterRemoved(filters.copyWith(clearMediaFormatId: true)),
      ));
    }

    if (filters.venueTypeId != null) {
      final name = DiscoverLabels.dictionaryLabel(
              venueTypes, filters.venueTypeId, DiscoverLabels.venue) ??
          'izabrana';
      chips.add(_FilterChipData(
        label: 'Lokacija: $name',
        onRemove: () =>
            onFilterRemoved(filters.copyWith(clearVenueTypeId: true)),
      ));
    }

    if (filters.environment != null) {
      chips.add(_FilterChipData(
        label:
            'Okruženje: ${DiscoverLabels.environment(filters.environment!).toLowerCase()}',
        onRemove: () =>
            onFilterRemoved(filters.copyWith(clearEnvironment: true)),
      ));
    }

    if (filters.illumination != null) {
      chips.add(_FilterChipData(
        label:
            'Osvetljenje: ${DiscoverLabels.illumination(filters.illumination!).toLowerCase()}',
        onRemove: () =>
            onFilterRemoved(filters.copyWith(clearIllumination: true)),
      ));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      final min = filters.minPrice;
      final max = filters.maxPrice;
      final label = min != null && max != null
          ? 'Cena: ${SrFormat.money(min, null)} – ${SrFormat.money(max, null)}'
          : (min != null
              ? 'Cena od ${SrFormat.money(min, null)}'
              : 'Cena do ${SrFormat.money(max, null)}');
      chips.add(_FilterChipData(
        label: label,
        onRemove: () => onFilterRemoved(
          filters.copyWith(clearMinPrice: true, clearMaxPrice: true),
        ),
      ));
    }

    if (filters.keyword != null && filters.keyword!.isNotEmpty) {
      chips.add(_FilterChipData(
        label: 'Pretraga: „${filters.keyword}“',
        onRemove: () => onFilterRemoved(filters.copyWith(clearKeyword: true)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: padding,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final chip in chips)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InputChip(
                  label: Text(chip.label),
                  labelStyle: AppTypography.labelMedium.copyWith(
                    color: AppColors.primaryStrong,
                    fontWeight: FontWeight.w600,
                  ),
                  deleteIcon: const Icon(Icons.close_rounded, size: 16),
                  deleteIconColor: AppColors.primaryStrong,
                  deleteButtonTooltipMessage: 'Ukloni filter',
                  onDeleted: chip.onRemove,
                  backgroundColor: AppColors.primarySoft,
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            TextButton(
              onPressed: onClearAll,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mutedForeground,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: AppTypography.labelMedium
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              child: const Text('Obriši sve'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChipData {
  final String label;
  final VoidCallback onRemove;

  const _FilterChipData({required this.label, required this.onRemove});
}
