import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../blocs/discover_bloc.dart';

class ViewToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onChanged;

  const ViewToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleButton(
            icon: Icons.grid_view_rounded,
            mode: ViewMode.grid,
            isFirst: true,
          ),
          _buildToggleButton(
            icon: Icons.view_list_rounded,
            mode: ViewMode.list,
          ),
          _buildToggleButton(
            icon: Icons.map_rounded,
            mode: ViewMode.mapOnly,
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required ViewMode mode,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isActive = currentMode == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(7) : Radius.zero,
            right: isLast ? const Radius.circular(7) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : AppColors.mutedForeground,
        ),
      ),
    );
  }
}
