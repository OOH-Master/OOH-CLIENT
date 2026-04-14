import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_constants.dart';
import '../../../../core/theme/app_typography.dart';
import '../../data/repository/inventory_management_repository.dart';
import '../blocs/inventory_management_bloc.dart';
import '../widgets/image_upload_widget.dart';
import '../widgets/map_location_picker.dart';

class InventoryFormPage extends StatelessWidget {
  final String? inventoryId;

  const InventoryFormPage({super.key, this.inventoryId});

  bool get isEditing => inventoryId != null;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          InventoryManagementBloc(context.read<InventoryManagementRepository>()),
      child: _InventoryFormView(inventoryId: inventoryId, isEditing: isEditing),
    );
  }
}

class _InventoryFormView extends StatefulWidget {
  final String? inventoryId;
  final bool isEditing;

  const _InventoryFormView({this.inventoryId, required this.isEditing});

  @override
  State<_InventoryFormView> createState() => _InventoryFormViewState();
}

class _InventoryFormViewState extends State<_InventoryFormView> {
  final _formKey = GlobalKey<FormState>();
  final _siteNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _priceController = TextEditingController();
  String? _currency = 'EUR';
  String? _cycleType = 'ONE_MONTH';
  String? _environment;
  String? _illumination;
  double? _lat;
  double? _lng;
  bool _showPreview = false;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void dispose() {
    _siteNameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.isEditing ? l10n.editInventory : l10n.createInventory),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.foreground,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                setState(() => _showPreview = !_showPreview);
              }
            },
            icon: Icon(
              _showPreview ? Icons.edit : Icons.preview,
              size: 18,
              color: AppColors.primary,
            ),
            label: Text(
              _showPreview ? 'Izmeni' : 'Pregled',
              style: AppTypography.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
        ],
      ),
      body: BlocConsumer<InventoryManagementBloc, InventoryManagementState>(
        listener: (context, state) {
          if (state is InventoryFormSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.pop();
          }
          if (state is InventoryManagementError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.destructive,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is InventoryManagementLoading;

          if (_showPreview) {
            return _buildPreviewView(isLoading);
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: _siteNameController,
                    label: l10n.siteName,
                    required: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _descriptionController,
                    label: l10n.description,
                    maxLines: 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildTextField(
                    controller: _addressController,
                    label: l10n.address,
                    required: true,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Environment chips
                  _buildSectionLabel(l10n.environment),
                  const SizedBox(height: 8),
                  _buildChipOptions(
                    ['INDOOR', 'OUTDOOR', 'ROADSIDE', 'MALL', 'AIRPORT', 'TRANSIT'],
                    _environment,
                    (v) => setState(() => _environment = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // Illumination chips
                  _buildSectionLabel(l10n.illumination),
                  const SizedBox(height: 8),
                  _buildChipOptions(
                    ['ILLUMINATED', 'FRONTLIT', 'BACKLIT', 'NOT_ILLUMINATED'],
                    _illumination,
                    (v) => setState(() => _illumination = v),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextField(
                          controller: _priceController,
                          label: l10n.price,
                          keyboardType: TextInputType.number,
                          required: true,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _buildDropdown(
                          label: l10n.currency,
                          value: _currency,
                          items: ['EUR', 'USD', 'RSD'],
                          onChanged: (v) => setState(() => _currency = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildDropdown(
                    label: l10n.cycleType,
                    value: _cycleType,
                    items: ['ONE_DAY', 'ONE_WEEK', 'TWO_WEEK', 'FOUR_WEEK', 'ONE_MONTH'],
                    onChanged: (v) => setState(() => _cycleType = v),
                  ),
                  // Map location picker
                  const SizedBox(height: AppSpacing.lg),
                  MapLocationPicker(
                    initialLat: _lat,
                    initialLng: _lng,
                    onLocationSelected: (LatLng location) {
                      setState(() {
                        _lat = location.latitude;
                        _lng = location.longitude;
                      });
                    },
                  ),
                  // Image Upload (only when editing)
                  if (widget.isEditing) ...[
                    const SizedBox(height: AppSpacing.lg),
                    ImageUploadWidget(
                      existingImages: const [],
                      onImagesAdded: (List<XFile> files) {
                        // TODO: implement image upload API call
                      },
                      onImageRemoved: (int index) {
                        // TODO: implement image removal API call
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(l10n.save),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPreviewView(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview header
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Icon(Icons.preview, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Pregled pre cuvanja',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildPreviewRow('Naziv', _siteNameController.text),
          if (_descriptionController.text.isNotEmpty)
            _buildPreviewRow('Opis', _descriptionController.text),
          _buildPreviewRow('Adresa', _addressController.text),
          if (_environment != null)
            _buildPreviewRow('Okruzenje', _environment!.replaceAll('_', ' ')),
          if (_illumination != null)
            _buildPreviewRow('Osvetljenje', _illumination!.replaceAll('_', ' ')),
          _buildPreviewRow(
            'Cena',
            '${_currency ?? 'EUR'} ${_priceController.text}/${_cycleType?.replaceAll('_', ' ') ?? 'ONE MONTH'}',
          ),
          if (_lat != null && _lng != null)
            _buildPreviewRow(
              'Koordinate',
              '${_lat!.toStringAsFixed(5)}, ${_lng!.toStringAsFixed(5)}',
            ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handleSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.primaryForeground,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(l10n.save),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(color: AppColors.mutedForeground),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool required = false,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: required
          ? (v) => (v == null || v.isEmpty) ? l10n.validatorRequired : null
          : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: AppTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: AppColors.foreground,
      ),
    );
  }

  Widget _buildChipOptions(
    List<String> options,
    String? selected,
    ValueChanged<String?> onChanged,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final isSelected = selected == option;
        return ChoiceChip(
          label: Text(option.replaceAll('_', ' ')),
          selected: isSelected,
          onSelected: (_) => onChanged(isSelected ? null : option),
          selectedColor: AppColors.primary.withValues(alpha: 0.15),
          backgroundColor: AppColors.muted,
          labelStyle: AppTypography.bodySmall.copyWith(
            color: isSelected ? AppColors.primary : AppColors.foreground,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item.replaceAll('_', ' ')),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{
      'siteName': _siteNameController.text,
      'fullAddress': _addressController.text,
      'pricePerCycle': double.tryParse(_priceController.text),
      'currency': _currency,
      'cycleType': _cycleType,
    };

    if (_descriptionController.text.isNotEmpty) {
      data['description'] = _descriptionController.text;
    }
    if (_environment != null) data['environment'] = _environment;
    if (_illumination != null) data['illumination'] = _illumination;
    if (_lat != null) data['lat'] = _lat;
    if (_lng != null) data['lng'] = _lng;

    final bloc = context.read<InventoryManagementBloc>();
    if (widget.isEditing) {
      final id = int.tryParse(widget.inventoryId!);
      if (id != null) bloc.add(UpdateInventoryItem(id, data));
    } else {
      bloc.add(CreateInventoryItem(data));
    }
  }
}
