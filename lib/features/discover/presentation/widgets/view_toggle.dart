import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../blocs/discover_bloc.dart';

/// Prikaz rezultata: mreža, lista ili samo mapa.
class ViewToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onChanged;
  final List<ViewMode> modes;

  const ViewToggle({
    super.key,
    required this.currentMode,
    required this.onChanged,
    this.modes = const [ViewMode.grid, ViewMode.list, ViewMode.mapOnly],
  });

  static (IconData, String) _meta(ViewMode mode) {
    switch (mode) {
      case ViewMode.grid:
        return (Icons.grid_view_rounded, 'Mreža');
      case ViewMode.list:
        return (Icons.view_agenda_outlined, 'Lista');
      case ViewMode.mapOnly:
        return (Icons.map_outlined, 'Samo mapa');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final mode in modes) _segment(mode),
        ],
      ),
    );
  }

  Widget _segment(ViewMode mode) {
    final (icon, label) = _meta(mode);
    final active = currentMode == mode;
    return Tooltip(
      message: label,
      child: GestureDetector(
        onTap: () => onChanged(mode),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            width: 38,
            height: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? AppColors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              size: 18,
              color: active ? AppColors.primary : AppColors.mutedForeground,
            ),
          ),
        ),
      ),
    );
  }
}
