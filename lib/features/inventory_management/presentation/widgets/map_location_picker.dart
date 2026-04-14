import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';

class MapLocationPicker extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;
  final ValueChanged<LatLng> onLocationSelected;

  const MapLocationPicker({
    super.key,
    this.initialLat,
    this.initialLng,
    required this.onLocationSelected,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.map, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Lokacija na mapi',
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Kliknite na mapu da postavite lokaciju',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.mutedForeground,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.sm),
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
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.ooh.mobile',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _selectedLocation,
                    width: 40,
                    height: 40,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Lat: ${_selectedLocation.latitude.toStringAsFixed(5)}, '
          'Lng: ${_selectedLocation.longitude.toStringAsFixed(5)}',
          style: AppTypography.caption.copyWith(color: AppColors.mutedForeground),
        ),
      ],
    );
  }
}
