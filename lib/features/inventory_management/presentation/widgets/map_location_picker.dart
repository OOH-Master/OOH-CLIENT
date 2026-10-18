import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

/// Mapa za izbor tačne lokacije površine: klik na mapu postavlja tačku.
class MapLocationPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final ValueChanged<LatLng> onLocationSelected;

  /// Da li je tačka već izabrana (sačuvana ili kliknuta); bez nje se prikazuje
  /// uputstvo, a oznaka je providna.
  final bool hasLocation;
  final double height;

  const MapLocationPicker({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationSelected,
    this.hasLocation = true,
    this.height = 260,
  });

  @override
  State<MapLocationPicker> createState() => _MapLocationPickerState();
}

class _MapLocationPickerState extends State<MapLocationPicker> {
  late LatLng _selectedLocation;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedLocation = LatLng(
      widget.initialLat ?? 44.8176,
      widget.initialLng ?? 20.4633,
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.border),
          ),
          clipBehavior: Clip.antiAlias,
          child: FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation,
              initialZoom: 13.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
                widget.onLocationSelected(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ooh.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 44,
                    height: 44,
                    alignment: Alignment.topCenter,
                    child: Opacity(
                      opacity: widget.hasLocation ? 1 : 0.45,
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.hasLocation
              ? '${_selectedLocation.latitude.toStringAsFixed(5)}, '
                  '${_selectedLocation.longitude.toStringAsFixed(5)}'
              : 'Kliknite na mapu da označite tačnu lokaciju.',
          style: AppTypography.caption.copyWith(
            color: AppColors.mutedForeground,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
