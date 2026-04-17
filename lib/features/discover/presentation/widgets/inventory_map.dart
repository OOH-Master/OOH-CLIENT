import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ooh_unit.dart';

class InventoryMap extends StatefulWidget {
  final List<OohUnit> units;
  final LatLng center;
  final double zoom;
  final OohUnit? selectedUnit;
  final Function(OohUnit)? onUnitTap;
  final Function(OohUnit)? onUnitDetailTap;

  const InventoryMap({
    super.key,
    required this.units,
    required this.center,
    this.zoom = 13.0,
    this.selectedUnit,
    this.onUnitTap,
    this.onUnitDetailTap,
  });

  @override
  State<InventoryMap> createState() => _InventoryMapState();
}

class _InventoryMapState extends State<InventoryMap> with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  @override
  void didUpdateWidget(InventoryMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Center map when selected unit changes
    if (widget.selectedUnit != null &&
        widget.selectedUnit?.id != oldWidget.selectedUnit?.id) {
      _animatedMapMove(
        LatLng(widget.selectedUnit!.latitude, widget.selectedUnit!.longitude),
        15.0,
      );
    }
    // Animate when center or zoom changes (city/country selection)
    else if (widget.center != oldWidget.center || widget.zoom != oldWidget.zoom) {
      _animatedMapMove(widget.center, widget.zoom);
    }
  }

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final latTween = Tween<double>(
      begin: _mapController.camera.center.latitude,
      end: destLocation.latitude,
    );
    final lngTween = Tween<double>(
      begin: _mapController.camera.center.longitude,
      end: destLocation.longitude,
    );
    final zoomTween = Tween<double>(
      begin: _mapController.camera.zoom,
      end: destZoom,
    );

    final controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    final animation = CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    );

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed || status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.zoom,
            minZoom: 5.0,
            maxZoom: 18.0,
            onTap: (_, __) {
              if (widget.selectedUnit != null) {
                widget.onUnitTap?.call(widget.selectedUnit!);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.ooh.mobile',
              maxZoom: 19,
            ),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 80,
                size: const Size(50, 50),
                showPolygon: false,
                disableClusteringAtZoom: 16,
                markers: widget.units.map((unit) {
                  return Marker(
                    point: LatLng(unit.latitude, unit.longitude),
                    width: 40,
                    height: 40,
                    child: GestureDetector(
                      onTap: () {
                        widget.onUnitTap?.call(unit);
                        _mapController.move(
                          LatLng(unit.latitude, unit.longitude),
                          15.0,
                        );
                      },
                      child: _buildMarker(unit),
                    ),
                  );
                }).toList(),
                builder: (context, markers) {
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        markers.length.toString(),
                        style: AppTypography.labelMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        // Enhanced popup card for selected unit
        if (widget.selectedUnit != null)
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: _buildEnhancedPopupCard(widget.selectedUnit!),
          ),
      ],
    );
  }

  Widget _buildEnhancedPopupCard(OohUnit unit) {
    return GestureDetector(
      onTap: () => widget.onUnitDetailTap?.call(unit),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
              child: Container(
                width: 120,
                height: 110,
                color: AppColors.muted,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    unit.imageUrl != null
                        ? Image.network(
                            unit.imageUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                          )
                        : _buildImagePlaceholder(),
                    // Type badge overlay
                    Positioned(
                      top: 6,
                      left: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _getTypeColor(unit.type).withValues(alpha: 0.9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Icon(
                          _getMarkerIcon(unit),
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: unit.isAvailable
                                ? AppColors.success.withValues(alpha: 0.1)
                                : AppColors.destructive.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: unit.isAvailable ? AppColors.success : AppColors.destructive,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                unit.isAvailable ? 'Dostupno' : 'Zauzeto',
                                style: AppTypography.labelSmall.copyWith(
                                  color: unit.isAvailable ? AppColors.success : AppColors.destructive,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => widget.onUnitTap?.call(unit),
                          child: Icon(Icons.close, size: 18, color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      unit.name,
                      style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: AppColors.mutedForeground),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            '${unit.cityName}, ${unit.address}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.mutedForeground),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.priceDisplay,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Detalji',
                            style: AppTypography.labelSmall.copyWith(color: Colors.white),
                          ),
                        ),
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

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppColors.muted,
      child: Center(
        child: Icon(Icons.image, size: 32, color: AppColors.mutedForeground),
      ),
    );
  }

  Widget _buildMarker(OohUnit unit) {
    final isSelected = widget.selectedUnit?.id == unit.id;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : unit.isAvailable
                  ? _getTypeColor(unit.type)
                  : Colors.grey,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: isSelected ? 3 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: isSelected ? 8 : 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            _getMarkerIcon(unit),
            color: Colors.white,
            size: isSelected ? 24 : 20,
          ),
        ),
      ),
    );
  }

  /// Different colors based on media type
  Color _getTypeColor(OohType type) {
    switch (type) {
      case OohType.billboard:
        return const Color(0xFF3B82F6); // Blue
      case OohType.digital:
        return const Color(0xFF8B5CF6); // Purple
      case OohType.subway:
        return const Color(0xFFF59E0B); // Amber
      case OohType.airport:
        return const Color(0xFF10B981); // Green
      case OohType.bus:
        return const Color(0xFFEF4444); // Red
      case OohType.other:
        return const Color(0xFF6B7280); // Gray
    }
  }

  IconData _getMarkerIcon(OohUnit unit) {
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

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}
