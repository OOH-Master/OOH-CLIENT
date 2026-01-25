import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_constants.dart';
import '../../domain/entities/ooh_unit.dart';

class InventoryCard extends StatelessWidget {
  final OohUnit unit;
  final VoidCallback? onTap;
  final bool isCompact;
  final bool isSelected;

  const InventoryCard({
    super.key,
    required this.unit,
    this.onTap,
    this.isCompact = false,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            Padding(
              padding: EdgeInsets.all(isCompact ? AppSpacing.sm : AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  SizedBox(height: AppSpacing.xs),
                  _buildAddress(),
                  SizedBox(height: AppSpacing.sm),
                  _buildFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        color: AppColors.muted,
        child: unit.imageUrl != null
            ? Image.network(
                unit.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
              )
            : _buildPlaceholder(),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.muted,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getTypeIcon(),
            size: 48,
            color: AppColors.mutedForeground,
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            _getTypeName(),
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                unit.name,
                style: isCompact 
                    ? AppTypography.labelLarge.copyWith(fontWeight: FontWeight.w600)
                    : AppTypography.h6,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2),
              _buildStatusBadge(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color badgeColor;
    String badgeText;

    switch (unit.status) {
      case OohStatus.available:
        badgeColor = AppColors.success;
        badgeText = 'Available';
        break;
      case OohStatus.booked:
        badgeColor = AppColors.warning;
        badgeText = 'Booked';
        break;
      case OohStatus.maintenance:
        badgeColor = AppColors.mutedForeground;
        badgeText = 'Maintenance';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        badgeText,
        style: AppTypography.labelSmall.copyWith(
          color: badgeColor,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildAddress() {
    return Row(
      children: [
        Icon(
          Icons.location_on_outlined,
          size: 16,
          color: AppColors.mutedForeground,
        ),
        SizedBox(width: 4),
        Expanded(
          child: Text(
            '${unit.address}, ${unit.cityName}',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.mutedForeground,
            ),
            maxLines: isCompact ? 1 : 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              unit.priceDisplay,
              style: AppTypography.h5.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        if (!isCompact)
          OutlinedButton.icon(
            onPressed: onTap,
            icon: Icon(Icons.info_outline, size: 16),
            label: Text('Details'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
            ),
          ),
      ],
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

  String _getTypeName() {
    switch (unit.type) {
      case OohType.billboard:
        return 'Billboard';
      case OohType.digital:
        return 'Digital Display';
      case OohType.subway:
        return 'Subway Ad';
      case OohType.airport:
        return 'Airport Display';
      case OohType.bus:
        return 'Bus Shelter';
      case OohType.other:
        return 'OOH Unit';
    }
  }
}
