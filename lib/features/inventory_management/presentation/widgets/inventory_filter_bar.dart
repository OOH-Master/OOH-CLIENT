import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class InventoryFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String? activeStatusFilter;
  final String currentSort;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String?> onStatusFilterChanged;
  final ValueChanged<String> onSortChanged;

  const InventoryFilterBar({
    super.key,
    required this.searchController,
    required this.activeStatusFilter,
    required this.currentSort,
    required this.onSearchChanged,
    required this.onStatusFilterChanged,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search bar
        TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.foreground),
          decoration: InputDecoration(
            hintText: 'Pretrazi inventar...',
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.mutedForeground),
            prefixIcon: Icon(Icons.search, color: AppColors.mutedForeground, size: 20),
            suffixIcon: searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, size: 18, color: AppColors.mutedForeground),
                    onPressed: () {
                      searchController.clear();
                      onSearchChanged('');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              borderSide: BorderSide(color: AppColors.border),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        // Filter chips + sort
        Row(
          children: [
            // Status chips
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildStatusChip(null, 'Sve', context),
                    const SizedBox(width: 8),
                    _buildStatusChip('ACTIVE', 'Aktivno', context),
                    const SizedBox(width: 8),
                    _buildStatusChip('DISABLED', 'Neaktivno', context),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            // Sort dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentSort,
                  isDense: true,
                  icon: Icon(Icons.sort, size: 16, color: AppColors.mutedForeground),
                  dropdownColor: Colors.white,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Naziv')),
                    DropdownMenuItem(value: 'date', child: Text('Datum')),
                    DropdownMenuItem(value: 'price', child: Text('Cena')),
                  ],
                  onChanged: (v) {
                    if (v != null) onSortChanged(v);
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String? value, String label, BuildContext context) {
    final isActive = activeStatusFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isActive,
      onSelected: (_) => onStatusFilterChanged(isActive ? null : value),
      selectedColor: AppColors.primary.withValues(alpha: 0.15),
      backgroundColor: AppColors.muted,
      labelStyle: AppTypography.bodySmall.copyWith(
        color: isActive ? AppColors.primary : AppColors.foreground,
        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.full),
        side: BorderSide(
          color: isActive ? AppColors.primary : AppColors.border,
        ),
      ),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    );
  }
}
