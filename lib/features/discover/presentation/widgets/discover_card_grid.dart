import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ooh_unit.dart';

class DiscoverCardGrid extends StatelessWidget {
  final OohUnit unit;
  final bool isSelected;
  final bool isSelectedForInquiry;
  final VoidCallback? onTap;
  final VoidCallback? onAddToInquiry;

  const DiscoverCardGrid({
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image with media type badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: AppColors.muted,
                      child: unit.imageUrl != null
                          ? Image.network(
                              unit.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                            )
                          : _buildImagePlaceholder(),
                    ),
                    // Media type icon badge (top-left)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.foreground.withValues(alpha: 0.75),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          _getTypeIcon(unit.type),
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                    // Add to inquiry button (top-right)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onAddToInquiry,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isSelectedForInquiry
                                ? AppColors.primary
                                : Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(6),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                          child: Icon(
                            isSelectedForInquiry
                                ? Icons.check
                                : Icons.add_shopping_cart,
                            color: isSelectedForInquiry
                                ? Colors.white
                                : AppColors.primary,
                            size: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Unit name
                    Text(
                      unit.name,
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.foreground,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Location
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.mutedForeground),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${unit.cityName}, ${unit.address}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // Price + availability
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.priceDisplay,
                            style: AppTypography.bodySmall.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 4),
                        _buildAvailabilityDot(),
                      ],
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

  Widget _buildAvailabilityDot() {
    final isAvailable = unit.isAvailable;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: isAvailable ? AppColors.success : AppColors.destructive,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          isAvailable ? 'Dostupno' : 'Zauzeto',
          style: AppTypography.caption.copyWith(
            color: isAvailable ? AppColors.success : AppColors.destructive,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.muted,
      child: Center(
        child: Icon(
          _getTypeIcon(unit.type),
          size: 32,
          color: AppColors.mutedForeground,
        ),
      ),
    );
  }

  static IconData _getTypeIcon(OohType type) {
    switch (type) {
      case OohType.billboard:
        return Icons.campaign;
      case OohType.digital:
        return Icons.monitor;
      case OohType.subway:
        return Icons.subway;
      case OohType.airport:
        return Icons.flight;
      case OohType.bus:
        return Icons.directions_bus;
      case OohType.other:
        return Icons.location_city;
    }
  }
}
