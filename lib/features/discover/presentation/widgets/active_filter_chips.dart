import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/api/inventory_api_service.dart';
import '../../data/dto/dto.dart';

class ActiveFilterChips extends StatelessWidget {
  final InventoryFilterParams filters;
  final List<DictionaryRefDto> unitTypes;
  final List<DictionaryRefDto> mediaFormats;
  final List<DictionaryRefDto> venueTypes;
  final void Function(InventoryFilterParams updatedFilters) onFilterRemoved;
  final VoidCallback onClearAll;

  const ActiveFilterChips({
    super.key,
    required this.filters,
    this.unitTypes = const [],
    this.mediaFormats = const [],
    this.venueTypes = const [],
    required this.onFilterRemoved,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final chips = <_FilterChipData>[];

    if (filters.unitTypeId != null) {
      final name = unitTypes
          .where((t) => t.id == filters.unitTypeId)
          .map((t) => t.name)
          .firstOrNull ?? 'Tip #${filters.unitTypeId}';
      chips.add(_FilterChipData(
        label: 'Tip: $name',
        onRemove: () => onFilterRemoved(filters.copyWith(clearUnitTypeId: true)),
      ));
    }

    if (filters.mediaFormatId != null) {
      final name = mediaFormats
          .where((t) => t.id == filters.mediaFormatId)
          .map((t) => t.name)
          .firstOrNull ?? 'Format #${filters.mediaFormatId}';
      chips.add(_FilterChipData(
        label: 'Format: $name',
        onRemove: () => onFilterRemoved(filters.copyWith(clearMediaFormatId: true)),
      ));
    }

    if (filters.venueTypeId != null) {
      final name = venueTypes
          .where((t) => t.id == filters.venueTypeId)
          .map((t) => t.name)
          .firstOrNull ?? 'Lokacija #${filters.venueTypeId}';
      chips.add(_FilterChipData(
        label: 'Lokacija: $name',
        onRemove: () => onFilterRemoved(filters.copyWith(clearVenueTypeId: true)),
      ));
    }

    if (filters.environment != null) {
      chips.add(_FilterChipData(
        label: 'Okruzenje: ${_envLabel(filters.environment!)}',
        onRemove: () => onFilterRemoved(filters.copyWith(clearEnvironment: true)),
      ));
    }

    if (filters.illumination != null) {
      chips.add(_FilterChipData(
        label: 'Osvetljenje: ${_illumLabel(filters.illumination!)}',
        onRemove: () => onFilterRemoved(filters.copyWith(clearIllumination: true)),
      ));
    }

    if (filters.minPrice != null || filters.maxPrice != null) {
      final min = filters.minPrice?.toStringAsFixed(0) ?? '0';
      final max = filters.maxPrice?.toStringAsFixed(0) ?? '...';
      chips.add(_FilterChipData(
        label: 'Cena: \u20AC$min - \u20AC$max',
        onRemove: () => onFilterRemoved(
          filters.copyWith(clearMinPrice: true, clearMaxPrice: true),
        ),
      ));
    }

    if (filters.keyword != null && filters.keyword!.isNotEmpty) {
      chips.add(_FilterChipData(
        label: 'Pretraga: "${filters.keyword}"',
        onRemove: () => onFilterRemoved(filters.copyWith(clearKeyword: true)),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...chips.map((chip) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InputChip(
                    label: Text(
                      chip.label,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    deleteIcon: Icon(Icons.close, size: 14, color: AppColors.primary),
                    onDeleted: chip.onRemove,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                    side: BorderSide(color: AppColors.primary.withValues(alpha: 0.2)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                )),
            TextButton.icon(
              onPressed: onClearAll,
              icon: Icon(Icons.clear_all, size: 16, color: AppColors.mutedForeground),
              label: Text(
                'Obrisi sve',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mutedForeground,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _envLabel(String value) {
    switch (value) {
      case 'INDOOR':
        return 'Unutra';
      case 'OUTDOOR':
        return 'Spolja';
      case 'ROADSIDE':
        return 'Pored puta';
      case 'MALL':
        return 'Trzni centar';
      case 'AIRPORT':
        return 'Aerodrom';
      case 'TRANSIT':
        return 'Tranzit';
      default:
        return value;
    }
  }

  String _illumLabel(String value) {
    switch (value) {
      case 'ILLUMINATED':
        return 'Osvetljeno';
      case 'FRONTLIT':
        return 'Frontlit';
      case 'BACKLIT':
        return 'Backlit';
      case 'NOT_ILLUMINATED':
        return 'Neosvetljeno';
      default:
        return value;
    }
  }
}

class _FilterChipData {
  final String label;
  final VoidCallback onRemove;

  const _FilterChipData({required this.label, required this.onRemove});
}
