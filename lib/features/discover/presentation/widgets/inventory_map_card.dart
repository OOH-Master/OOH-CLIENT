import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../domain/entities/ooh_unit.dart';

class InventoryMapCard extends StatelessWidget {
  final OohUnit unit;
  final VoidCallback onClose;
  final VoidCallback onViewDetails;

  const InventoryMapCard({
    super.key,
    required this.unit,
    required this.onClose,
    required this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildThumbnail(),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          unit.name,
                          style: AppTypography.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.close, size: 20),
                        onPressed: onClose,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    unit.address,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        unit.priceDisplay,
                        style: AppTypography.h6.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onViewDetails,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                        child: Text('View Details'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.muted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: unit.imageUrl != null
          ? ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: Image.network(
                unit.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              ),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildPlaceholder() {
    return Icon(
      _getTypeIcon(),
      size: 32,
      color: AppColors.mutedForeground,
    );
  }

  IconData _getTypeIcon() {
    switch (unit.type) {
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
