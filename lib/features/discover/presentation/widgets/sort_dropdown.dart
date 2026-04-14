import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../blocs/discover_bloc.dart';

class SortDropdown extends StatelessWidget {
  final SortOption currentSort;
  final ValueChanged<SortOption> onChanged;

  const SortDropdown({
    super.key,
    required this.currentSort,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<SortOption>(
          value: currentSort,
          isDense: true,
          icon: Icon(Icons.sort, size: 16, color: AppColors.mutedForeground),
          dropdownColor: Colors.white,
          style: AppTypography.bodySmall.copyWith(color: AppColors.foreground),
          items: const [
            DropdownMenuItem(
              value: SortOption.newest,
              child: Text('Najnovije'),
            ),
            DropdownMenuItem(
              value: SortOption.priceAsc,
              child: Text('Cena (niska-visoka)'),
            ),
            DropdownMenuItem(
              value: SortOption.priceDesc,
              child: Text('Cena (visoka-niska)'),
            ),
          ],
          onChanged: (value) {
            if (value != null) onChanged(value);
          },
        ),
      ),
    );
  }
}
