import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/ooh_unit.dart';
import 'inventory_map_card.dart';
import 'unit_labels.dart';

class InventoryMap extends StatefulWidget {
  final List<OohUnit> units;
  final LatLng center;
  final double zoom;
  final OohUnit? selectedUnit;
  final Function(OohUnit)? onUnitTap;
  final Function(OohUnit)? onUnitDetailTap;

  /// Površina nad čijom karticom je miš: njena oznaka se ističe bez pomeranja mape.
  final ValueListenable<String?>? highlightedUnitId;

  /// Da li je površina u korpi za upit (za dugme na kartici iznad mape).
  final bool Function(OohUnit)? isInInquiry;
  final Function(OohUnit)? onToggleInquiry;

  /// Donji deo mape prekriva lista (telefon): kartica i natpis idu gore.
  final bool overlayed;

  const InventoryMap({
    super.key,
    required this.units,
    required this.center,
    this.zoom = 13.0,
    this.selectedUnit,
    this.onUnitTap,
    this.onUnitDetailTap,
    this.highlightedUnitId,
    this.isInInquiry,
    this.onToggleInquiry,
    this.overlayed = false,
  });

  @override
  State<InventoryMap> createState() => _InventoryMapState();
}

class _InventoryMapState extends State<InventoryMap>
    with TickerProviderStateMixin {
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
    else if (widget.center != oldWidget.center ||
        widget.zoom != oldWidget.zoom) {
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
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  static bool _hasCoords(OohUnit u) => u.latitude != 0 || u.longitude != 0;

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    _animatedMapMove(camera.center, (camera.zoom + delta).clamp(5.0, 18.0));
  }

  /// Prikazuje sve površine iz rezultata.
  void _fitToUnits() {
    final points = widget.units
        .where(_hasCoords)
        .map((u) => LatLng(u.latitude, u.longitude))
        .toList();
    if (points.isEmpty) {
      _animatedMapMove(widget.center, widget.zoom);
      return;
    }
    if (points.length == 1) {
      _animatedMapMove(points.first, 15);
      return;
    }
    final fitted = CameraFit.coordinates(
      coordinates: points,
      padding: const EdgeInsets.all(56),
      maxZoom: 15,
    ).fit(_mapController.camera);
    _animatedMapMove(fitted.center, fitted.zoom);
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selectedUnit;
    final markers = [
      for (final unit in widget.units.where(_hasCoords))
        Marker(
          point: LatLng(unit.latitude, unit.longitude),
          width: 48,
          height: 48,
          child: GestureDetector(
            onTap: () {
              widget.onUnitTap?.call(unit);
              _mapController.move(
                LatLng(unit.latitude, unit.longitude),
                15.0,
              );
            },
            child: _UnitMarker(
              unit: unit,
              selected: selected?.id == unit.id,
              highlight: widget.highlightedUnitId,
            ),
          ),
        ),
    ];

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.center,
            initialZoom: widget.zoom,
            minZoom: 5.0,
            maxZoom: 18.0,
            backgroundColor: const Color(0xFFE9ECF3),
            onTap: (_, __) {
              if (widget.selectedUnit != null) {
                widget.onUnitTap?.call(widget.selectedUnit!);
              }
            },
          ),
          children: [
            const DiscoverTileLayer(),
            MarkerClusterLayerWidget(
              options: MarkerClusterLayerOptions(
                maxClusterRadius: 80,
                size: const Size(50, 50),
                computeSize: (markers) {
                  final n = markers.length;
                  final d = n < 10 ? 44.0 : (n < 50 ? 52.0 : 60.0);
                  return Size(d, d);
                },
                showPolygon: false,
                disableClusteringAtZoom: 16,
                markers: markers,
                builder: (context, markers) =>
                    _ClusterBubble(count: markers.length),
              ),
            ),
          ],
        ),
        Positioned(
          left: 10,
          top: widget.overlayed ? 10 : null,
          bottom: widget.overlayed ? null : 10,
          child: const MapAttributionLabel(),
        ),
        if (!(widget.overlayed && selected != null))
          Positioned(
            top: 12,
            right: 12,
            child: _MapControls(
              onZoomIn: () => _zoomBy(1),
              onZoomOut: () => _zoomBy(-1),
              onFit: _fitToUnits,
            ),
          ),
        if (selected != null)
          Positioned(
            left: 12,
            right: 12,
            top: widget.overlayed ? 12 : null,
            bottom: widget.overlayed ? null : 16,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: InventoryMapCard(
                  unit: selected,
                  onClose: () => widget.onUnitTap?.call(selected),
                  onViewDetails: () => widget.onUnitDetailTap?.call(selected),
                  isSelectedForInquiry:
                      widget.isInInquiry?.call(selected) ?? false,
                  onToggleInquiry: widget.onToggleInquiry == null
                      ? null
                      : () => widget.onToggleInquiry!(selected),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}

/// Podloga mape: OpenStreetMap prigušenih boja, da se indigo oznake jasno vide.
class DiscoverTileLayer extends StatelessWidget {
  const DiscoverTileLayer({super.key});

  // Zasićenost oko 30% uz blago hladan ton.
  static const List<double> _muted = <double>[
    0.449, 0.501, 0.051, 0, 8, //
    0.149, 0.801, 0.051, 0, 8, //
    0.149, 0.501, 0.356, 0, 16, //
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    // Jedan filter boja za ceo sloj, a ne za svaku pločicu posebno.
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_muted),
      child: TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'com.ooh.mobile',
        maxZoom: 19,
      ),
    );
  }
}

/// Obavezan natpis izvora podloge mape.
class MapAttributionLabel extends StatelessWidget {
  const MapAttributionLabel({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Text(
          '© OpenStreetMap',
          style: AppTypography.caption.copyWith(
            fontSize: 10.5,
            color: AppColors.mutedForeground,
          ),
        ),
      ),
    );
  }
}

/// Indigo oznaka površine sa belim prstenom; izabrana ili istaknuta je veća.
class _UnitMarker extends StatelessWidget {
  final OohUnit unit;
  final bool selected;
  final ValueListenable<String?>? highlight;

  const _UnitMarker({
    required this.unit,
    required this.selected,
    required this.highlight,
  });

  @override
  Widget build(BuildContext context) {
    final listenable = highlight;
    if (listenable == null) return _dot(selected);
    return ValueListenableBuilder<String?>(
      valueListenable: listenable,
      builder: (context, id, _) => _dot(selected || id == unit.id),
    );
  }

  Widget _dot(bool active) {
    final d = active ? 38.0 : 28.0;
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutBack,
        width: d,
        height: d,
        decoration: BoxDecoration(
          color: active ? AppColors.primaryStrong : AppColors.primary,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: active ? 3 : 2.5),
        ),
        child: Icon(
          unit.isDigitalUnit
              ? Icons.bolt_rounded
              : Icons.crop_landscape_rounded,
          size: active ? 18 : 14,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Grupa oznaka: indigo krug sa brojem.
class _ClusterBubble extends StatelessWidget {
  final int count;

  const _ClusterBubble({required this.count});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          '$count',
          style: AppTypography.money.copyWith(
            color: Colors.white,
            fontSize: count < 100 ? 14 : 12.5,
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// Uvećanje, umanjenje i prikaz svih površina.
class _MapControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onFit;

  const _MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onFit,
  });

  @override
  Widget build(BuildContext context) {
    Widget button(IconData icon, String tooltip, VoidCallback onTap) {
      return Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap,
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 19, color: AppColors.text2),
          ),
        ),
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.md - 1),
        child: Material(
          type: MaterialType.transparency,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              button(Icons.add_rounded, 'Uvećaj', onZoomIn),
              const SizedBox(width: 36, child: Divider(height: 1)),
              button(Icons.remove_rounded, 'Umanji', onZoomOut),
              const SizedBox(width: 36, child: Divider(height: 1)),
              button(Icons.fit_screen_outlined, 'Prikaži sve površine', onFit),
            ],
          ),
        ),
      ),
    );
  }
}
