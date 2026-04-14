import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ooh_unit.dart';

class DiscoverCardList extends StatelessWidget {
  final OohUnit unit;
  final bool isSelected;
  final bool isSelectedForInquiry;
  final VoidCallback? onTap;
  final VoidCallback? onAddToInquiry;

  const DiscoverCardList({
    super.key,
    required this.unit,
    this.isSelected = false,
    this.isSelectedForInquiry = false,
    this.onTap,
    this.onAddToInquiry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(7)),
              child: SizedBox(
                width: 60,
                height: 60,
                child: unit.imageUrl != null
                    ? Image.network(
                        unit.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Name + location
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            unit.name,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.foreground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${unit.cityName}, ${unit.address}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Price
                    Text(
                      unit.priceDisplay,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status dot
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: unit.isAvailable ? AppColors.success : AppColors.destructive,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Add to inquiry
                    GestureDetector(
                      onTap: onAddToInquiry,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isSelectedForInquiry
                              ? AppColors.primary
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          isSelectedForInquiry
                              ? Icons.check
                              : Icons.add_shopping_cart,
                          color: isSelectedForInquiry
                              ? Colors.white
                              : AppColors.primary,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.muted,
      child: Center(
        child: Icon(Icons.image, size: 24, color: AppColors.mutedForeground),
      ),
    );
  }
}
