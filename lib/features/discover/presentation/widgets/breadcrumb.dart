import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

/// Putanja "Istraži › Beograd › Naziv": prethodni koraci su linkovi, poslednji
/// se skraćuje kada nema mesta.
class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      final item = items[i];
      final last = i == items.length - 1;
      if (i > 0) {
        children.add(const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Icon(Icons.chevron_right_rounded,
              size: 18, color: AppColors.subtle),
        ));
      }
      if (last) {
        children.add(Flexible(
          child: Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelMedium.copyWith(
              color: AppColors.foreground,
              fontWeight: FontWeight.w600,
            ),
          ),
        ));
      } else {
        children.add(_CrumbLink(item: item));
      }
    }
    return Row(children: children);
  }
}

class _CrumbLink extends StatelessWidget {
  final BreadcrumbItem item;

  const _CrumbLink({required this.item});

  @override
  Widget build(BuildContext context) {
    final style = AppTypography.labelMedium.copyWith(
      color: item.onTap != null ? AppColors.primary : AppColors.mutedForeground,
      fontWeight: FontWeight.w500,
    );
    if (item.onTap == null) return Text(item.label, style: style);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: item.onTap,
        child: Text(item.label, style: style),
      ),
    );
  }
}
