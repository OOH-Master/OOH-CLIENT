import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

class BreadcrumbItem {
  final String label;
  final VoidCallback? onTap;

  const BreadcrumbItem({required this.label, this.onTap});
}

class Breadcrumb extends StatelessWidget {
  final List<BreadcrumbItem> items;

  const Breadcrumb({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.chevron_right,
                  size: 16,
                  color: AppColors.mutedForeground,
                ),
              ),
            if (i < items.length - 1 && items[i].onTap != null)
              GestureDetector(
                onTap: items[i].onTap,
                child: Text(
                  items[i].label,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.primary,
                  ),
                ),
              )
            else
              Text(
                items[i].label,
                style: AppTypography.bodySmall.copyWith(
                  color: i == items.length - 1
                      ? AppColors.foreground
                      : AppColors.mutedForeground,
                  fontWeight:
                      i == items.length - 1 ? FontWeight.w500 : FontWeight.w400,
                ),
              ),
          ],
        ],
      ),
    );
  }
}
